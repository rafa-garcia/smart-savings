# frozen_string_literal: true

workers 2
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }
