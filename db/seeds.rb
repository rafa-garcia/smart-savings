# frozen_string_literal: true

require 'csv'

users_data        = CSV.read('db/users.csv', headers: true)
transactions_data = CSV.read('db/transactions.csv', headers: true)

users_data.each_with_index do |user_record, idx|
  user_idx = idx + 1
  user = SmartSavings::Models::User.create(
    name: user_record['name'],
    age: user_record['age']
  )
  transactions_data
    .select { |t| t['user_id'] == user_idx.to_s }
    .each do |transaction_record|
      user.add_transaction(
        amount: transaction_record['amount'],
        type: transaction_record['type'],
        created_at: transaction_record['created_at']
      )
    end
end
