# frozen_string_literal: true

class PropertiesController < ApplicationController
  before_action :set_property, only: %i[edit update destroy]
  load_and_authorize_resource except: %i[create new]

  def index
    @q = Property.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @properties = pagy(:offset, @q.result.includes(:producer, :address), limit: 15)
  end

  def new
    @property = Property.new
    @property.build_address
    @producers = Producer.all
    authorize! :create, Property
  end

  def create
    @property = Property.new(property_params)
    @property.tenant = Current.tenant
    @producers = Producer.all
    authorize! :create, @property

    if @property.save
      redirect_to properties_path, notice: t("properties.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @property.build_address if @property.address.nil?
    @producers = Producer.all
  end

  def update
    @producers = Producer.all
    if @property.update(property_params)
      redirect_to properties_path, notice: t("properties.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy!
    redirect_to properties_path, notice: t("properties.destroyed"), status: :see_other
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def property_params
    params.require(:property).permit(
      :name, :status, :incra, :registration, :activity, :localization, :producer_id,
      address_attributes: %i[id street number complement neighborhood city state zip_code country]
    )
  end
end
