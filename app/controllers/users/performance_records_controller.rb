# frozen_string_literal: true

module Users
  class PerformanceRecordsController < Users::BaseController
    before_action :set_performance_record, only: %i[edit update destroy]
    before_action :authorize_hr_write!, only: %i[new create edit update destroy]

    def new
      @performance_record = @user.user_performance_records.build(recorded_on: Date.current)
    end

    def create
      @performance_record = @user.user_performance_records.build(performance_record_params)
      @performance_record.tenant = Current.tenant

      if @performance_record.save
        redirect_to user_path(@user), notice: t("users.employee.performance_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @performance_record.update(performance_record_params)
        redirect_to user_path(@user), notice: t("users.employee.performance_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @performance_record.destroy
      redirect_to user_path(@user), notice: t("users.employee.performance_destroyed")
    end

    private

    def set_performance_record
      @performance_record = @user.user_performance_records.find(params[:id])
    end

    def performance_record_params
      params.require(:user_performance_record).permit(:recorded_on, :title, :notes, :rating)
    end
  end
end
