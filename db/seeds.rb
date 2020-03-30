# frozen_string_literal: true

require 'csv'

users_data = CSV.read('db/users.csv', headers: true)
users_data.each do |record|
  SmartSavings::Models::User.create(
    name: record[1], age: record[2], balance: record[3]
  )
end
