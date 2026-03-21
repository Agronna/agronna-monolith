# frozen_string_literal: true

class AllowNullScheduledAtOnSchedules < ActiveRecord::Migration[8.1]
  def change
    change_column_null :schedules, :scheduled_at, true
  end
end
