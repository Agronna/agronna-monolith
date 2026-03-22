# frozen_string_literal: true

class CreateUserGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :user_goals do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :target_date
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :user_goals, [ :user_id, :status ]
  end
end
