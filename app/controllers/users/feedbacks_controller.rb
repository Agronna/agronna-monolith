# frozen_string_literal: true

module Users
  class FeedbacksController < Users::BaseController
    before_action :set_feedback, only: %i[edit update destroy]
    before_action :authorize_hr_write!, only: %i[new create edit update destroy]

    def new
      @feedback = @user.user_feedbacks.build(feedback_on: Date.current, given_by: current_user, kind: :general)
      @feedback_givers = User.where(tenant: Current.tenant).order(:name)
    end

    def create
      @feedback = @user.user_feedbacks.build(feedback_params)
      @feedback.tenant = Current.tenant
      @feedback.given_by ||= current_user

      if @feedback.save
        redirect_to user_path(@user), notice: t("users.employee.feedback_created")
      else
        @feedback_givers = User.where(tenant: Current.tenant).order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @feedback_givers = User.where(tenant: Current.tenant).order(:name)
    end

    def update
      if @feedback.update(feedback_params)
        redirect_to user_path(@user), notice: t("users.employee.feedback_updated")
      else
        @feedback_givers = User.where(tenant: Current.tenant).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @feedback.destroy
      redirect_to user_path(@user), notice: t("users.employee.feedback_destroyed")
    end

    private

    def set_feedback
      @feedback = @user.user_feedbacks.find(params[:id])
    end

    def feedback_params
      params.require(:user_feedback).permit(:feedback_on, :kind, :content, :given_by_id)
    end
  end
end
