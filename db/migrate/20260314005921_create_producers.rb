class CreateProducers < ActiveRecord::Migration[8.1]
  def change
    create_table :producers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :status, default: 0, null: false
      t.string :phone, null: false
      t.string :cpf, null: false
      t.date :birth_date, null: false

      t.timestamps
    end
  end
end
