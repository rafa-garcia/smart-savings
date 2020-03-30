# frozen_string_literal: true

threads_count = Integer(ENV['MAX_THREADS'] || 5)
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV.fetch('PORT', 3000)
environment ENV.fetch('RACK_ENV', 'development')

on_worker_boot do
  if defined?(Sequel)
    Sequel::Model.db.disconnect
    Sequel::DATABASES.each(&:disconnect)
  end
end
