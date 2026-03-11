# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "guest", only: [ :new, :create ]
  skip_before_action :require_login, only: [ :new, :create ]
  skip_before_action :check_session_expiry, only: [ :new, :create ]
  before_action :require_tenant, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:expires_at] = 12.hours.from_now
      redirect_to root_path, notice: t("sessions.signed_in")
    else
      flash.now[:alert] = t("sessions.invalid_credentials")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: t("sessions.signed_out")
  end

  private

  def require_tenant
    return if Current.tenant.present?

    redirect_to root_path, alert: t("errors.tenant_required")
  end
end
