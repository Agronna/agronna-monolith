class AddSecretaryToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :secretary, null: true, foreign_key: true, index: true
  end
end
