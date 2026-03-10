class CreateSecretaries < ActiveRecord::Migration[8.1]
  def change
    create_table :secretaries do |t|
      t.string :cnpj, null: false
      t.string :corporate_name, null: false
      t.string :email, null: false
      t.string :name, null: false
      t.string :prefecture_name, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
