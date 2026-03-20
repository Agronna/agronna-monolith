class ServiceOrdersController < ApplicationController
  before_action :set_service_order, only: %i[show edit update destroy start complete cancel]
  before_action :set_form_collections, only: %i[new create edit update]
  load_and_authorize_resource except: %i[create new]
  before_action :ensure_service_order_editable, only: %i[edit update]
  before_action :ensure_service_order_not_cancelled, only: %i[cancel]

  def index
    @q = ServiceOrder.where(tenant: Current.tenant)
                     .includes(:secretary, :property, :assigned_to, :machines)
                     .ransack(params[:q])
    @q.sorts = "deadline asc" if @q.sorts.empty?
    @pagy, @service_orders = pagy(@q.result(distinct: true), limit: 15)
  end

  def show; end

  def new
    @service_order = ServiceOrder.new(
      tenant: Current.tenant,
      requested_by: current_user,
      deadline: Date.current + 7.days,
      priority: :normal
    )
    authorize! :create, ServiceOrder
  end

  def edit; end

  def create
    @service_order = ServiceOrder.new(service_order_params)
    @service_order.tenant = Current.tenant
    @service_order.requested_by ||= current_user
    authorize! :create, @service_order

    if @service_order.save
      redirect_to service_orders_path, notice: t("service_orders.created")
    else
      set_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @service_order.update(service_order_params)
      redirect_to service_orders_path, notice: t("service_orders.updated")
    else
      set_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_order.destroy
    redirect_to service_orders_path, notice: t("service_orders.destroyed")
  end

  def start
    unless @service_order.payment_receipt_approved?
      redirect_to service_orders_path, alert: t("service_orders.cannot_start_no_receipt")
      return
    end
    if @service_order.start!
      redirect_to service_orders_path, notice: t("service_orders.started")
    else
      redirect_to service_orders_path, alert: t("service_orders.cannot_start")
    end
  end

  def complete
    if @service_order.complete!
      redirect_to service_orders_path, notice: t("service_orders.completed")
    else
      redirect_to service_orders_path, alert: t("service_orders.cannot_complete")
    end
  end

  def cancel
    if @service_order.cancel!
      redirect_to service_orders_path, notice: t("service_orders.cancelled")
    else
      redirect_to service_orders_path, alert: t("service_orders.cannot_cancel")
    end
  end

  private

  def set_service_order
    @service_order = ServiceOrder.includes(:payment_receipts).find(params[:id])
  end

  def set_form_collections
    @secretaries = Secretary.where(tenant: Current.tenant).status_active.order(:name)
    @properties = Property.where(tenant: Current.tenant).status_active.order(:name)
    @producers = Producer.where(tenant: Current.tenant).status_active.order(:name)
    @service_providers = ServiceProvider.where(tenant: Current.tenant).status_active.order(:name)
    @users = User.where(tenant: Current.tenant).order(:name)
    @machines = Machine.where(tenant: Current.tenant).status_active.order(:name)
  end

  def service_order_params
    params.require(:service_order).permit(
      :title, :description, :deadline, :scheduled_at,
      :status, :priority, :observations,
      :secretary_id, :property_id, :producer_id,
      :service_provider_id, :assigned_to_id,
      machine_ids: [],
      service_order_machines_attributes: [ :id, :machine_id, :hours_used, :notes, :_destroy ]
    )
  end

  def ensure_service_order_editable
    return unless @service_order.present?

    if @service_order.status_cancelled?
      redirect_to service_orders_path, alert: t("service_orders.cannot_edit_cancelled")
      return
    end

    if @service_order.payment_receipt_approved?
      redirect_to service_orders_path, alert: t("service_orders.cannot_edit_payment_approved")
      return
    end
  end

  def ensure_service_order_not_cancelled
    return unless @service_order.status_cancelled?

    redirect_to service_orders_path, alert: t("service_orders.cannot_cancel_cancelled")
  end
end
