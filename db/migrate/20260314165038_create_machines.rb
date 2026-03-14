class CreateMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :machines do |t|
      t.string :name, null: false
      t.integer :status, default: 0, null: false
      t.string :chassis, null: false
      t.string :plate, null: false
      t.integer :manufacturing_year, null: false
      t.string :function, null: false
      t.references :secretary, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
