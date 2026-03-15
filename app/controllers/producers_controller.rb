# frozen_string_literal: true

class ProducersController < ApplicationController
  before_action :set_producer, only: %i[edit update destroy]
  load_and_authorize_resource except: %i[create new]

  def index
    @q = Producer.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @producers = pagy(:offset, @q.result, limit: 15)
  end

  def new
    @producer = Producer.new
    @producer.build_address
    authorize! :create, Producer
  end

  def create
    @producer = Producer.new(producer_params)
    @producer.tenant = Current.tenant
    authorize! :create, @producer

    if @producer.save
      redirect_to producers_path, notice: t("producers.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @producer.build_address if @producer.address.nil?
  end

  def update
    if @producer.update(producer_params)
      redirect_to producers_path, notice: t("producers.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producer.destroy!
    redirect_to producers_path, notice: t("producers.destroyed"), status: :see_other
  end

  private

  def set_producer
    @producer = Producer.find(params[:id])
  end

  def producer_params
    params.require(:producer).permit(
      :name, :email, :status, :phone, :cpf, :birth_date,
      address_attributes: %i[id street number complement neighborhood city state zip_code country]
    )
  end
end
