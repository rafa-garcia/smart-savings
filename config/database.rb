# frozen_string_literal: true

require 'logger'
require 'sequel'

begin
  db_name     = ENV.fetch('DB_NAME', "smart_savings_#{ENV['RACK_ENV']}")
  conn_config = {
    host: ENV.fetch('DB_HOST', 'localhost'),
    port: ENV.fetch('DB_PORT', 5432),
    user: ENV.fetch('DB_USERNAME', 'postgres'),
    password: ENV.fetch('DB_PASSWORD', 'postgres'),
    loggers: Logger.new(STDOUT)
  }

  DB = Sequel.postgres(db_name, conn_config)

  Sequel::Model.plugin :timestamps
  DB.extension :caller_logging, :pg_enum
rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError => e
  warn e.message
  abort 'Run `rake db:setup` to to kickstart the database'
end
