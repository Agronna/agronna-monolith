# frozen_string_literal: true

class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[start_service_order complete_service_order]
  before_action :authorize_service_order_transition, only: %i[start_service_order complete_service_order]
  before_action :set_form_collections, only: %i[new create edit update]
  load_and_authorize_resource except: %i[create new start_service_order complete_service_order]

  def index
    @q = Schedule.where(tenant: Current.tenant)
                 .includes(:secretary, :service_order, :machines, :assigned_users)
                 .ransack(params[:q])
    @q.sorts = "scheduled_at asc" if @q.sorts.empty?
    @pagy, @schedules = pagy(@q.result(distinct: true), limit: 15)
  end

  def calendar
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    @end_date = @start_date.end_of_month
    @filter_machine_id = params[:machine_id].presence
    @filter_user_id = params[:user_id].presence

    scope = Schedule.where(tenant: Current.tenant)
                    .for_calendar(@start_date, @end_date)
                    .where(status: [ :scheduled, :confirmed, :in_progress ])
                    .includes(:service_order, :machines, :assigned_users)
    scope = scope.joins(:schedule_machines).where(schedule_machines: { machine_id: @filter_machine_id }).distinct if @filter_machine_id.present?
    scope = scope.joins(:schedule_assignments).where(schedule_assignments: { user_id: @filter_user_id }).distinct if @filter_user_id.present?

    @schedules = scope.order(Arel.sql("COALESCE(service_orders.scheduled_at, schedules.scheduled_at)"))
    @schedules_by_date = @schedules.group_by { |s| s.calendar_starts_at&.to_date }.except(nil)
    @machines = Machine.where(tenant: Current.tenant).status_active.order(:name)
    @users = User.where(tenant: Current.tenant).order(:name)
  end

  def events
    start_date = params[:start].present? ? Time.zone.parse(params[:start]) : Date.current.beginning_of_month
    end_date = params[:end].present? ? Time.zone.parse(params[:end]) : Date.current.end_of_month

    scope = Schedule.where(tenant: Current.tenant)
                    .for_calendar(start_date, end_date)
                    .where(status: [ :scheduled, :confirmed, :in_progress ])
                    .includes(:service_order, :machines, :assigned_users)

    scope = scope.joins(:schedule_machines).where(schedule_machines: { machine_id: params[:machine_id] }).distinct if params[:machine_id].present?
    scope = scope.joins(:schedule_assignments).where(schedule_assignments: { user_id: params[:user_id] }).distinct if params[:user_id].present?

    events = scope.filter_map do |s|
      start_t = s.calendar_starts_at
      next unless start_t

      end_t = s.calendar_end_time || (start_t + 1.hour)
      {
        id: s.id,
        title: s.title_for_calendar,
        start: start_t.iso8601,
        end: end_t.iso8601,
        url: schedule_path(s),
        backgroundColor: schedule_color(s),
        extendedProps: {
          code: s.service_order.code,
          status: s.status,
          machines: s.machines.pluck(:name).join(", "),
          users: s.assigned_users.pluck(:name).join(", ")
        }
      }
    end

    render json: events
  end

  def show; end

  def new
    @schedule = Schedule.new(
      tenant: Current.tenant,
      scheduled_at: nil,
      scheduled_end_at: nil
    )
    @schedule.service_order = ServiceOrder.find(params[:service_order_id]) if params[:service_order_id].present?
    @schedule.secretary = @schedule.service_order&.secretary
    authorize! :create, @schedule
  end

  def edit; end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.tenant = Current.tenant
    @schedule.scheduled_at = nil
    @schedule.scheduled_end_at = nil
    sync_schedule_machines_with_service_order
    build_schedule_assignments_from_user_ids(schedule_user_ids_param)
    authorize! :create, @schedule

    if @schedule.save
      redirect_to_after_save(t("schedules.created"))
    else
      set_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @schedule.assign_attributes(schedule_params)
    sync_schedule_machines_with_service_order
    build_schedule_assignments_from_user_ids(schedule_user_ids_param) if schedule_params_present?
    if @schedule.save
      redirect_to_after_save(t("schedules.updated"))
    else
      set_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def start_service_order
    order = @schedule.service_order

    unless order.payment_receipt_approved?
      redirect_to schedule_path(@schedule), alert: t("service_orders.cannot_start_no_receipt")
      return
    end

    now = Time.current
    ok = false
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless order.start!(at: now)

      schedule_attrs = { scheduled_at: now }
      schedule_attrs[:status] = :in_progress if @schedule.status_scheduled? || @schedule.status_confirmed?
      raise ActiveRecord::Rollback unless @schedule.update(schedule_attrs)

      order.update_column(:scheduled_at, now)
      ok = true
    end

    if ok
      redirect_to schedule_path(@schedule), notice: t("service_orders.started")
    else
      redirect_to schedule_path(@schedule), alert: t("service_orders.cannot_start")
    end
  end

  def complete_service_order
    order = @schedule.service_order
    now = Time.current

    ok = false
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless order.complete!(at: now)
      raise ActiveRecord::Rollback unless @schedule.update(scheduled_end_at: now, status: :completed)
      ok = true
    end

    if ok
      redirect_to schedule_path(@schedule), notice: t("service_orders.completed")
    else
      redirect_to schedule_path(@schedule), alert: t("service_orders.cannot_complete")
    end
  end

  def destroy
    service_order = @schedule.service_order
    @schedule.destroy
    if params[:return_to] == "service_order" && service_order
      redirect_to service_order_path(service_order), notice: t("schedules.destroyed")
    else
      redirect_to schedules_path, notice: t("schedules.destroyed")
    end
  end

  private

  def set_schedule
    @schedule = Schedule.includes(:service_order).find(params[:id])
  end

  def authorize_service_order_transition
    authorize! :read, @schedule
    authorize! :update, @schedule.service_order
  end

  def set_form_collections
    @service_orders = ServiceOrder.where(tenant: Current.tenant)
                                  .joins(:payment_receipts)
                                  .where(payment_receipts: { status: :approved })
                                  .where(status: [ :pending, :scheduled ])
                                  .distinct
                                  .order(deadline: :asc)
    @service_orders = [ @schedule.service_order ] + @service_orders.to_a if @schedule&.service_order.present? && @service_orders.exclude?(@schedule.service_order)
    @secretaries = Secretary.where(tenant: Current.tenant).status_active.order(:name)
    service_order_id = @schedule&.service_order_id || params[:service_order_id].presence || params.dig(:schedule, :service_order_id)
    service_order = ServiceOrder.where(tenant: Current.tenant).find_by(id: service_order_id)
    @machines = if service_order.present?
      service_order.machines.status_active.order(:name)
    else
      Machine.where(tenant: Current.tenant).status_active.order(:name)
    end
    @users = User.where(tenant: Current.tenant).order(:name)
  end

  def redirect_to_after_save(notice)
    if params[:return_to] == "service_order" && @schedule.service_order_id.present?
      redirect_to service_order_path(@schedule.service_order), notice: notice
    else
      redirect_to schedule_path(@schedule), notice: notice
    end
  end

  def schedule_color(schedule)
    case schedule.status
    when "scheduled" then "#0dcaf0"
    when "confirmed" then "#0d6efd"
    when "in_progress" then "#ffc107"
    when "completed" then "#198754"
    when "cancelled" then "#dc3545"
    else "#6c757d"
    end
  end

  def build_schedule_assignments_from_user_ids(user_ids)
    @schedule.schedule_assignments.destroy_all
    user_ids.uniq.each { |user_id| @schedule.schedule_assignments.build(user_id: user_id) }
  end

  def schedule_params_present?
    params[:schedule].present?
  end

  def sync_schedule_machines_with_service_order
    service_order = @schedule.service_order || @schedule&.service_order&.reload
    return unless service_order.present?

    # A regra do negócio: o maquinario do agendamento deve sempre refletir o maquinario da OS.
    @schedule.machine_ids = service_order.machines.pluck(:id)
  end

  def schedule_machine_ids_param
    raw = params.dig(:schedule, :machine_ids)
    Array(raw).reject(&:blank?).map(&:to_i)
  end

  def schedule_user_ids_param
    raw = params.dig(:schedule, :user_ids)
    Array(raw).reject(&:blank?).map(&:to_i)
  end

  # Apenas atributos reais da tabela schedules. machine_ids / user_ids são handled via associações.
  def schedule_params
    params.require(:schedule).permit(
      :status, :observations,
      :secretary_id, :service_order_id,
      :return_to,
      machine_ids: [],
      user_ids: []
    ).except(:return_to, :machine_ids, :user_ids)
  end
end
