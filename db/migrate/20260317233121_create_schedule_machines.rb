# frozen_string_literal: true

class CreateScheduleMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_machines do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :machine, null: false, foreign_key: true
      t.decimal :hours_planned, precision: 6, scale: 2
      t.text :notes

      t.timestamps
    end

    add_index :schedule_machines, [ :schedule_id, :machine_id ], unique: true, name: "idx_schedule_machines_unique"
  end
end
