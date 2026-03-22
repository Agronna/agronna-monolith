# frozen_string_literal: true

module Users
  class GoalsController < Users::BaseController
    before_action :set_goal, only: %i[edit update destroy]
    before_action :authorize_hr_write!, only: %i[new create edit update destroy]

    def new
      @goal = @user.user_goals.build(status: :pending)
    end

    def create
      @goal = @user.user_goals.build(goal_params)
      @goal.tenant = Current.tenant

      if @goal.save
        redirect_to user_path(@user), notice: t("users.employee.goal_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @goal.update(goal_params)
        redirect_to user_path(@user), notice: t("users.employee.goal_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @goal.destroy
      redirect_to user_path(@user), notice: t("users.employee.goal_destroyed")
    end

    private

    def set_goal
      @goal = @user.user_goals.find(params[:id])
    end

    def goal_params
      params.require(:user_goal).permit(:title, :description, :target_date, :status)
    end
  end
end
