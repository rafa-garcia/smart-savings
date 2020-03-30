# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name, null: false
      Integer :age, null: false
      Float :balance, default: 0
      Integer :recommended_monthly_savings
      Time :created_at
    end
  end
end
