# frozen_string_literal: true

class ServiceProvidersController < ApplicationController
  before_action :set_service_provider, only: %i[edit update destroy]
  load_and_authorize_resource except: %i[create new]

  def index
    @q = ServiceProvider.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @service_providers = pagy(:offset, @q.result.includes(:secretary, :address), limit: 15)
  end

  def new
    @service_provider = ServiceProvider.new
    @service_provider.build_address
    @secretaries = Secretary.all
    authorize! :create, ServiceProvider
  end

  def create
    @service_provider = ServiceProvider.new(service_provider_params)
    @service_provider.tenant = Current.tenant
    @secretaries = Secretary.all
    authorize! :create, @service_provider

    if @service_provider.save
      redirect_to service_providers_path, notice: t("service_providers.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @service_provider.build_address if @service_provider.address.nil?
    @secretaries = Secretary.all
  end

  def update
    @secretaries = Secretary.all
    if @service_provider.update(service_provider_params)
      redirect_to service_providers_path, notice: t("service_providers.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_provider.destroy!
    redirect_to service_providers_path, notice: t("service_providers.destroyed"), status: :see_other
  end

  private

  def set_service_provider
    @service_provider = ServiceProvider.find(params[:id])
  end

  def service_provider_params
    params.require(:service_provider).permit(
      :name, :email, :telephone, :status, :service_type, :cnpj, :corporate_name, :secretary_id,
      address_attributes: %i[id street number complement neighborhood city state zip_code country]
    )
  end
end
