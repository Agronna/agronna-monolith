# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "guest"
  skip_before_action :require_tenant
  skip_before_action :require_login
  skip_before_action :check_session_expiry

  def tenant_required
    # Se o tenant existir, redireciona para a home
    redirect_to root_path if Current.tenant.present?
  end
end
