class Property < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :producer

  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address, allow_destroy: true

  validates :name, presence: true
  validates :activity, presence: true
  validates :producer_id, presence: true
  validates :tenant_id, presence: true

  validate :producer_must_belong_to_tenant

  enum :status, { inactive: 0, active: 1 }, prefix: true

  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :incra, with: ->(incra) { incra.to_s.strip }
  normalizes :registration, with: ->(registration) { registration.to_s.strip }
  normalizes :localization, with: ->(localization) { localization.to_s.strip }

  def self.ransackable_attributes(auth_object = nil)
    %w[name incra registration localization activity]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[producer tenant address]
  end

  private

  def producer_must_belong_to_tenant
    return if producer_id.blank? || tenant_id.blank?
    return if producer&.tenant_id == tenant_id

    errors.add(:producer_id, :invalid)
  end
end
