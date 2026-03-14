class Secretary < ApplicationRecord
  audited

  include BelongsToTenant

  has_one :address, as: :addressable, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
  has_many :machines, dependent: :restrict_with_error
  has_many :service_orders, dependent: :restrict_with_error
  has_many :service_providers, dependent: :restrict_with_error

  accepts_nested_attributes_for :address, allow_destroy: true

  validates :cnpj, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :corporate_name, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :name, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :prefecture_name, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :tenant_id, presence: true

  enum :status, { inactive: 0, active: 1 }, prefix: true
  normalizes :cnpj, with: ->(cnpj) { cnpj.to_s.strip.gsub(/[^0-9]/, "") }
  normalizes :corporate_name, with: ->(corporate_name) { corporate_name.to_s.strip }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :prefecture_name, with: ->(prefecture_name) { prefecture_name.to_s.strip }

  # Filtros: apenas name, cnpj, email e prefecture_name
  def self.ransackable_attributes(auth_object = nil)
    %w[name cnpj email prefecture_name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[address tenant users]
  end
end
