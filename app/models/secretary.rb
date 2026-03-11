class Secretary < ApplicationRecord
  include BelongsToTenant

  has_many :users, dependent: :restrict_with_error
  # has_many :agendamentos, dependent: :restrict_with_error
  # etc. — descomente ao criar as tabelas relacionadas

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
end
