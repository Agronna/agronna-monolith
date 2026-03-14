class AddTenantToProducers < ActiveRecord::Migration[8.1]
  def change
    add_reference :producers, :tenant, null: false, foreign_key: true
  end
end
