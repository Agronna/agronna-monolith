# frozen_string_literal: true

class AddOwnerToTenants < ActiveRecord::Migration[8.1]
  def change
    add_reference :tenants, :owner, foreign_key: { to_table: :users }, index: true
  end
end
