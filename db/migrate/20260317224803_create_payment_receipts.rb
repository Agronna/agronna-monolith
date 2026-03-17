# frozen_string_literal: true

class CreatePaymentReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_receipts do |t|
      # Dados do pagamento
      t.date :payment_date, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :reference
      t.text :description

      # Origem (manual vs importação bancária)
      t.integer :source, default: 0, null: false

      # Status de validação
      t.integer :status, default: 0, null: false
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.text :rejection_reason

      # Dados de importação bancária (quando source = bank_import)
      t.string :bank_name
      t.string :bank_code
      t.string :transaction_code
      t.string :external_id

      t.text :observations

      # Relacionamentos
      t.references :tenant, null: false, foreign_key: true
      t.references :secretary, null: false, foreign_key: true
      t.references :service_order, null: false, foreign_key: true
      t.references :producer, foreign_key: true

      t.timestamps
    end

    add_index :payment_receipts, :payment_date
    add_index :payment_receipts, :status
    add_index :payment_receipts, :source
    add_index :payment_receipts, :external_id
  end
end
