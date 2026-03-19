# frozen_string_literal: true

class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.datetime :scheduled_at, null: false
      t.datetime :scheduled_end_at
      t.integer :status, default: 0, null: false
      t.text :observations

      t.references :tenant, null: false, foreign_key: true
      t.references :secretary, null: false, foreign_key: true
      t.references :service_order, null: false, foreign_key: true

      t.timestamps
    end

    add_index :schedules, :scheduled_at
    add_index :schedules, :status
  end
end
