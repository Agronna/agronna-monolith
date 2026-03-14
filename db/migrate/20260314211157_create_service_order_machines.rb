# frozen_string_literal: true

class CreateServiceOrderMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :service_order_machines do |t|
      t.references :service_order, null: false, foreign_key: true
      t.references :machine, null: false, foreign_key: true
      t.decimal :hours_used, precision: 8, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
