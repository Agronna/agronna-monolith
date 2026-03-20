class Machine < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :secretary

  has_many :service_order_machines, dependent: :restrict_with_error
  has_many :service_orders, through: :service_order_machines
  has_many :schedule_machines, dependent: :restrict_with_error
  has_many :schedules, through: :schedule_machines

  validates :name, presence: true
  validates :chassis, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :plate, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :manufacturing_year, presence: true, numericality: { only_integer: true, greater_than: 1900 }
  validates :function, presence: true
  validates :secretary_id, presence: true
  validates :tenant_id, presence: true

  validate :secretary_must_belong_to_tenant

  enum :status, { inactive: 0, active: 1 }, prefix: true

  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :chassis, with: ->(chassis) { chassis.to_s.strip.upcase }
  normalizes :plate, with: ->(plate) { plate.to_s.strip.upcase.gsub(/[^A-Z0-9]/, "") }
  normalizes :function, with: ->(function) { function.to_s.strip }

  def self.ransackable_attributes(auth_object = nil)
    %w[name chassis plate function manufacturing_year]
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
end
