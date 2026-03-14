# frozen_string_literal: true

class MachinesController < ApplicationController
  before_action :set_machine, only: %i[edit update destroy]
  load_and_authorize_resource except: %i[create new]

  def index
    @q = Machine.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @machines = pagy(:offset, @q.result.includes(:secretary), limit: 15)
  end

  def new
    @machine = Machine.new
    @secretaries = Secretary.all
    authorize! :create, Machine
  end

  def create
    @machine = Machine.new(machine_params)
    @machine.tenant = Current.tenant
    @secretaries = Secretary.all
    authorize! :create, @machine

    if @machine.save
      redirect_to machines_path, notice: t("machines.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @secretaries = Secretary.all
  end

  def update
    @secretaries = Secretary.all
    if @machine.update(machine_params)
      redirect_to machines_path, notice: t("machines.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @machine.destroy!
    redirect_to machines_path, notice: t("machines.destroyed"), status: :see_other
  end

  private

  def set_machine
    @machine = Machine.find(params[:id])
  end

  def machine_params
    params.require(:machine).permit(
      :name, :status, :chassis, :plate, :manufacturing_year, :function, :secretary_id
    )
  end
end
