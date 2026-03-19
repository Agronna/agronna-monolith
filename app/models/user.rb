class User < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :secretary, optional: true
  has_one :owned_tenant, class_name: "Tenant", foreign_key: :owner_id, dependent: :nullify
  has_many :schedule_assignments, dependent: :restrict_with_error
  has_many :schedules, through: :schedule_assignments

  has_secure_password

  enum :role, { user: 0, sub_admin: 1, admin: 2 }, prefix: true

  validates :name, presence: true
  validates :secretary_id, presence: true
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
    length: { minimum: 6 },
    format: {
      with: /\A(?=.*[A-Z])(?=.*[\W_]).+\z/,
      message: "Deve conter ao menos uma letra maiúscula e um caractere especial"
    },
    if: -> { password.present? }
  validate :secretary_must_belong_to_tenant

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

  # Ransack: atributos e associações permitidos para busca
  def self.ransackable_attributes(auth_object = nil)
    %w[name email created_at role secretary_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[secretary tenant]
  end

  private

  def secretary_must_belong_to_tenant
    return if secretary_id.blank? || tenant_id.blank?
    return if secretary&.tenant_id == tenant_id

    errors.add(:secretary_id, :invalid)
  end

  def assign_as_owner_if_first_admin
    return unless role_admin?
    return if tenant.owner_id.present?

    tenant.update_column(:owner_id, id)
  end
end
