class CreateServiceProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :service_providers do |t|
      t.string :name
      t.string :email
      t.string :telephone
      t.integer :status
      t.string :service_type
      t.string :cnpj
      t.string :corporate_name
      t.references :secretary, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
