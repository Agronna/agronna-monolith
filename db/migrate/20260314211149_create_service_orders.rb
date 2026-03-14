# frozen_string_literal: true

class CreateServiceOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :service_orders do |t|
      t.string :code, null: false
      t.string :title, null: false
      t.text :description
      t.date :deadline, null: false
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.text :observations
      t.references :tenant, null: false, foreign_key: true
      t.references :secretary, null: false, foreign_key: true
      t.references :property, foreign_key: true
      t.references :producer, foreign_key: true
      t.references :service_provider, foreign_key: true
      t.references :requested_by, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
