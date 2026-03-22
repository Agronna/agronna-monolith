# frozen_string_literal: true

# Apenas admin pode cadastrar sub-admins (usuários da secretaria).
# Sub-admin e user podem apenas editar o próprio perfil.
class UsersController < ApplicationController
  load_and_authorize_resource except: [ :create, :new, :show ]

  def index
    @q = User.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @users = pagy(:offset, @q.result.includes(:secretary), limit: 15)
  end

  def show
    @user = User.includes(:secretary, :user_performance_records, :user_goals, user_feedbacks: :given_by).find(params[:id])
    authorize! :read, @user
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

  def user_params
    p = params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :secretary_id, :job_title, :hired_on)
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
    list = [ :name, :email, :secretary_id, :job_title, :hired_on ]
    list << :role if current_user&.admin?
    list << :password << :password_confirmation if params[:user][:password].present?
    params.require(:user).permit(list)
  end
end
