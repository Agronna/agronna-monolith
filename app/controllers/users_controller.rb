# frozen_string_literal: true

# Apenas admin pode cadastrar sub-admins (usuários da secretaria).
# Sub-admin e user podem apenas editar o próprio perfil.
class UsersController < ApplicationController
  before_action :require_tenant
  load_and_authorize_resource except: [ :create, :new ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
    @secretaries = Secretary.all
    authorize! :create, User
  end

  def create
    @user = User.new(user_params)
    @user.tenant = Current.tenant
    @secretaries = Secretary.all
    authorize! :create, @user

    if @user.save
      redirect_to users_path, notice: t("users.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @secretaries = Secretary.all
  end

  def update
    if @user.update(update_params)
      redirect_to users_path, notice: t("users.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_tenant
    return if Current.tenant.present?

    redirect_to root_path, alert: t("errors.tenant_required")
  end

  def user_params
    p = params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :secretary_id)
    unless current_user&.admin?
      p.delete(:role)
    else
      # Admin pode criar apenas sub_admin ou user (não outro admin pela UI)
      p[:role] = "user" unless %w[sub_admin user].include?(p[:role])
    end
    p[:role] = "user" if p[:role].blank?
    p
  end

  def update_params
    list = [ :name, :email, :secretary_id ]
    list << :role if current_user&.admin?
    list << :password << :password_confirmation if params[:user][:password].present?
    params.require(:user).permit(list)
  end
end
