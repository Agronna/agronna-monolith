class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_tenant
  before_action :set_current_user
  before_action :check_session_expiry
  before_action :require_login

  helper_method :current_user

  private

  def set_current_tenant
    subdomain = request.subdomain.presence || request.env["HTTP_X_TENANT"]
    Current.tenant = Tenant.find_by_subdomain(subdomain) if subdomain.present?
  end

  def set_current_user
    return unless Current.tenant.present? && session[:user_id].present?

    Current.user = User.find_by(id: session[:user_id])
  end

  def current_user
    Current.user
  end

  def check_session_expiry
    return if session[:expires_at].blank?
    return if Time.current < session[:expires_at]

    reset_session
    redirect_to new_session_path, alert: t("sessions.expired")
  end

  def require_login
    # Sem tenant: não exige login (evita loop); a tela pode exibir aviso para acessar com subdomínio
    return if Current.tenant.blank?
    return if current_user.present?

    redirect_to new_session_path, alert: t("sessions.login_required")
  end
end
