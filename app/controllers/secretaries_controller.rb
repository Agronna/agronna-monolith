# frozen_string_literal: true

class SecretariesController < ApplicationController
  before_action :require_tenant
  before_action :set_secretary, only: %i[ edit update destroy ]
  load_and_authorize_resource except: [ :create, :new ]

  def index
    @q = Secretary.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @secretaries = pagy(:offset, @q.result, limit: 15)
  end

  def new
    @secretary = Secretary.new
    @secretary.build_address
    authorize! :create, Secretary
  end

  def create
    @secretary = Secretary.new(secretary_params)
    @secretary.tenant = Current.tenant
    authorize! :create, @secretary

    if @secretary.save
      redirect_to secretaries_path, notice: t("secretaries.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @secretary.build_address if @secretary.address.nil?
  end

  def update
    if @secretary.update(secretary_params)
      redirect_to secretaries_path, notice: t("secretaries.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @secretary.destroy!
    redirect_to secretaries_path, notice: t("secretaries.destroyed"), status: :see_other
  end

  private

  def set_secretary
    @secretary = Secretary.find(params[:id])
  end

  def require_tenant
    return if Current.tenant.present?

    redirect_to root_path, alert: t("errors.tenant_required")
  end

  def secretary_params
    params.require(:secretary).permit(
      :cnpj, :corporate_name, :email, :name, :prefecture_name, :status,
      address_attributes: [ :id, :street, :number, :complement, :neighborhood, :city, :state, :zip_code, :country ]
    )
  end
end
