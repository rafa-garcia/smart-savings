# frozen_string_literal: true

system 'export $(cat .env | xargs)'

require 'bundler/setup'

Bundler.require :default, ENV['RACK_ENV']

begin
  require 'api/service'
  require 'models/user'
  require 'models/transaction'
rescue Sequel::DatabaseError => e
  raise e unless e.wrapped_exception.class == PG::UndefinedTable

  abort 'Run `rake db:migrate` to to establish relations'
end
