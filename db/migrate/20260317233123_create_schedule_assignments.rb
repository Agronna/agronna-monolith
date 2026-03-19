# frozen_string_literal: true

class CreateScheduleAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_assignments do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.text :notes

      t.timestamps
    end

    add_index :schedule_assignments, [ :schedule_id, :user_id ], unique: true, name: "idx_schedule_assignments_unique"
  end
end
