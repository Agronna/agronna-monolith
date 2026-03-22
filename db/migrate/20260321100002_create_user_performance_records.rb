# frozen_string_literal: true

class CreateUserPerformanceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :user_performance_records do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :recorded_on, null: false
      t.string :title
      t.text :notes
      t.integer :rating

      t.timestamps
    end

    add_index :user_performance_records, [ :user_id, :recorded_on ]
  end
end
