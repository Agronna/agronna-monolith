# frozen_string_literal: true

class ServiceOrderMachine < ApplicationRecord
  audited associated_with: :service_order

  belongs_to :service_order
  belongs_to :machine

  validates :service_order_id, presence: true
  validates :machine_id, presence: true, uniqueness: { scope: :service_order_id }
  validates :hours_used, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  delegate :name, :plate, :function, to: :machine, prefix: true

  def self.ransackable_attributes(auth_object = nil)
    %w[hours_used notes]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[service_order machine]
  end
end
