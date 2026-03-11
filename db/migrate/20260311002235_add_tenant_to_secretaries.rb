class AddTenantToSecretaries < ActiveRecord::Migration[8.1]
  def change
    add_reference :secretaries, :tenant, null: true, foreign_key: true, index: true
  end
end
