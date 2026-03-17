# frozen_string_literal: true

class PaymentReceiptsController < ApplicationController
  before_action :set_payment_receipt, only: %i[show edit update destroy approve reject]
  before_action :set_form_collections, only: %i[new create edit update]
  load_and_authorize_resource except: %i[create new]

  def index
    @q = PaymentReceipt.where(tenant: Current.tenant)
                       .includes(:secretary, :service_order, :producer)
                       .ransack(params[:q])
    @q.sorts = "payment_date desc" if @q.sorts.empty?
    @pagy, @payment_receipts = pagy(@q.result(distinct: true), limit: 15)
  end

  def show; end

  def new
    @payment_receipt = PaymentReceipt.new(
      tenant: Current.tenant,
      payment_date: Date.current,
      source: :manual
    )
    @payment_receipt.service_order = ServiceOrder.find(params[:service_order_id]) if params[:service_order_id].present?
    @payment_receipt.secretary = @payment_receipt.service_order&.secretary
    @payment_receipt.producer = @payment_receipt.service_order&.producer
    authorize! :create, @payment_receipt
  end

  def edit; end

  def create
    @payment_receipt = PaymentReceipt.new(payment_receipt_params)
    @payment_receipt.tenant = Current.tenant
    @payment_receipt.source = :manual
    authorize! :create, @payment_receipt

    if @payment_receipt.save
      redirect_to_after_save(t("payment_receipts.created"))
    else
      set_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payment_receipt.update(payment_receipt_params)
      redirect_to_after_save(t("payment_receipts.updated"))
    else
      set_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service_order = @payment_receipt.service_order
    @payment_receipt.destroy
    if service_order
      redirect_to service_order_path(service_order), notice: t("payment_receipts.destroyed")
    else
      redirect_to payment_receipts_path, notice: t("payment_receipts.destroyed")
    end
  end

  def approve
    if @payment_receipt.approve!(current_user)
      redirect_to_after_save(t("payment_receipts.approved"))
    else
      redirect_to payment_receipt_path(@payment_receipt), alert: t("payment_receipts.cannot_approve")
    end
  end

  def reject
    reason = params[:rejection_reason]
    if @payment_receipt.reject!(current_user, reason)
      redirect_to_after_save(t("payment_receipts.rejected"))
    else
      redirect_to payment_receipt_path(@payment_receipt), alert: t("payment_receipts.cannot_reject")
    end
  end

  private

  def set_payment_receipt
    @payment_receipt = PaymentReceipt.find(params[:id])
  end

  def set_form_collections
    @service_orders = ServiceOrder.where(tenant: Current.tenant)
                                  .where(status: [ :pending, :scheduled ])
                                  .order(deadline: :asc)
    # Inclui a OS atual se veio por service_order_id e não está na lista (ex.: já em andamento)
    if @payment_receipt&.service_order.present? && @service_orders.exclude?(@payment_receipt.service_order)
      @service_orders = [ @payment_receipt.service_order ] + @service_orders.to_a
    end
    @secretaries = Secretary.where(tenant: Current.tenant).status_active.order(:name)
    @producers = Producer.where(tenant: Current.tenant).status_active.order(:name)
  end

  def redirect_to_after_save(notice)
    return_to = params[:return_to].presence || params.dig(:payment_receipt, :return_to)
    if return_to == "service_order" && @payment_receipt.service_order_id.present?
      redirect_to service_order_path(@payment_receipt.service_order), notice: notice
    else
      redirect_to payment_receipt_path(@payment_receipt), notice: notice
    end
  end

  def payment_receipt_params
    permitted = params.require(:payment_receipt).permit(
      :payment_date, :amount, :reference, :description, :observations,
      :secretary_id, :service_order_id, :producer_id,
      :return_to,
      :file
    )
    permitted.delete(:return_to)
    permitted
  end
end
