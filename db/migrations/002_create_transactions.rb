# frozen_string_literal: true

Sequel.migration do
  change do
    extension :pg_enum

    create_enum :transaction_type, %w[credit debit]

    create_table :transactions do
      primary_key :id
      foreign_key :user_id, :users, null: false
      Float :amount, null: false
      transaction_type :type, null: false
      Time :created_at
    end
  end
end
