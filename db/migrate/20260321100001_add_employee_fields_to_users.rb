# frozen_string_literal: true

class AddEmployeeFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :job_title, :string
    add_column :users, :hired_on, :date
  end
end
