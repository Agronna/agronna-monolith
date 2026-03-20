# frozen_string_literal: true

class ScheduleMachine < ApplicationRecord
  audited associated_with: :schedule

  belongs_to :schedule
  belongs_to :machine

  validates :schedule_id, presence: true
  validates :machine_id, presence: true, uniqueness: { scope: :schedule_id }
  validates :hours_planned, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
