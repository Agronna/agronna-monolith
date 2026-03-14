class Producer < ApplicationRecord
  audited

  include BelongsToTenant

  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address, allow_destroy: true

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :email, uniqueness: { scope: :tenant_id, case_sensitive: false }, allow_blank: true
  validates :tenant_id, presence: true

  enum :status, { inactive: 0, active: 1 }, prefix: true

  normalizes :cpf, with: ->(cpf) { cpf.to_s.strip.gsub(/[^0-9]/, "") }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :phone, with: ->(phone) { phone.to_s.strip.gsub(/[^0-9]/, "") }

  def self.ransackable_attributes(auth_object = nil)
    %w[name cpf email phone]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[address tenant]
  end
end
