# frozen_string_literal: true

class CreateUserFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :user_feedbacks do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :given_by, null: true, foreign_key: { to_table: :users }
      t.date :feedback_on, null: false
      t.integer :kind, null: false, default: 0
      t.text :content, null: false

      t.timestamps
    end

    add_index :user_feedbacks, [ :user_id, :feedback_on ]
  end
end
