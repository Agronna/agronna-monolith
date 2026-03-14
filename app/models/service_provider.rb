# frozen_string_literal: true

class ServiceProvider < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :secretary

  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address, allow_destroy: true

  validates :name, presence: true
  validates :cnpj, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :corporate_name, presence: true
  validates :service_type, presence: true
  validates :secretary_id, presence: true
  validates :tenant_id, presence: true

  validate :secretary_must_belong_to_tenant

  enum :status, { inactive: 0, active: 1 }, prefix: true

  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :telephone, with: ->(telephone) { telephone.to_s.strip.gsub(/[^0-9]/, "") }
  normalizes :cnpj, with: ->(cnpj) { cnpj.to_s.strip.gsub(/[^0-9]/, "") }
  normalizes :corporate_name, with: ->(corporate_name) { corporate_name.to_s.strip }
  normalizes :service_type, with: ->(service_type) { service_type.to_s.strip }

  def self.ransackable_attributes(auth_object = nil)
    %w[name email cnpj corporate_name service_type telephone]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[secretary tenant address]
  end

  private

  def secretary_must_belong_to_tenant
    return if secretary_id.blank? || tenant_id.blank?
    return if secretary&.tenant_id == tenant_id

    errors.add(:secretary_id, :invalid)
  end
end
