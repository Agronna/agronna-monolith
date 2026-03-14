class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.string :name, null: false
      t.integer :status, null: false
      t.string :incra
      t.string :registration
      t.text :activity, null: false
      t.string :localization
      t.references :producer, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
