# frozen_string_literal: true

class User < ApplicationRecord
  include BelongsToTenant

  has_secure_password

  has_one :owned_tenant, class_name: "Tenant", foreign_key: :owner_id, dependent: :nullify

  enum :role, { user: 0, sub_admin: 1, admin: 2 }, prefix: true

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  after_create :assign_as_owner_if_first_admin

  def admin?
    role_admin?
  end

  def sub_admin?
    role_sub_admin?
  end

  # Usuário principal da conta (administrador que pode adicionar outros usuários à conta)
  def account_owner?
    Current.tenant.present? && Current.tenant.owner_id == id
  end

  private

  def assign_as_owner_if_first_admin
    return unless role_admin?
    return if tenant.owner_id.present?

    tenant.update_column(:owner_id, id)
  end
end
