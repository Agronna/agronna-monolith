# frozen_string_literal: true

class ScheduleAssignment < ApplicationRecord
  audited associated_with: :schedule

  belongs_to :schedule
  belongs_to :user

  validates :schedule, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :schedule_id }
end
