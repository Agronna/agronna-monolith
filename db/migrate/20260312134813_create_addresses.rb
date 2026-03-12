class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.string :country
      t.string :state
      t.string :city
      t.string :zip_code
      t.string :neighborhood
      t.string :street
      t.string :number
      t.string :complement
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
