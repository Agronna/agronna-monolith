# frozen_string_literal: true

module Users
  class BaseController < ApplicationController
    before_action :set_user

    private

    def set_user
      @user = User.includes(:secretary).find(params[:user_id])
      authorize! :read, @user
    end

    def authorize_hr_write!
      authorize! :update, @user
    end
  end
end
