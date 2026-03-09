class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_tenant

  private

  def set_current_tenant
    subdomain = request.subdomain.presence || request.env["HTTP_X_TENANT"]
    Current.tenant = Tenant.find_by_subdomain(subdomain) if subdomain.present?
  end
end
