# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'sequel'

def connect(db_name = nil)
  db_config = {
    host: ENV.fetch('DB_HOST', 'localhost'),
    port: ENV.fetch('DB_PORT', 5432),
    user: ENV.fetch('DB_USERNAME', 'postgres'),
    password: ENV.fetch('DB_PASSWORD', 'postgres')
  }

  yield Sequel.postgres(db_name, db_config)
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

desc 'Start server'
task :server do
  system %(rackup -p 3000)
end
task s: :server

desc 'Start console'
task :console do
  system %(./bin/console)
end
task c: :console

desc 'Load app environment'
task :environment do
  ENV['RACK_ENV'] ||= 'development'
  require File.expand_path('config/environment', __dir__)
end

desc 'List API routes'
task routes: :environment do
  SmartSavings::API::Root.routes.each do |route|
    method = route.request_method.ljust(4)
    path   = route.path
    puts "#{method} #{path}"
  end
end

RSpec::Core::RakeTask.new(:spec)
task default: :spec

namespace :db do
  desc 'Create database'
  task :create do
    env     = ENV.fetch('RACK_ENV', :development)
    db_name = ENV.fetch('DB_NAME', "smart_savings_#{env}")

    begin
      print "Creating database #{db_name} on #{env} environment"
      connect do |conn|
        conn.execute "CREATE DATABASE #{db_name};"
      end
      puts ' - OK'
    rescue Sequel::DatabaseError => e
      puts ' -  FAIL'
      raise e unless e.wrapped_exception.class == PG::DuplicateDatabase

      abort "Database '#{db_name}' already exists"
    end
  end

  desc 'Drop database'
  task :drop do
    env     = ENV.fetch('RACK_ENV', :development)
    db_name = ENV.fetch('DB_NAME', "smart_savings_#{env}")

    print "Dropping database #{db_name} on #{env} environment"
    begin
      connect do |conn|
        conn.execute "DROP DATABASE IF EXISTS #{db_name};"
      end
      puts ' - OK'
    rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError => e
      puts ' -  FAIL'
      abort e.message
    end
  end

  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    Sequel.extension :migration

    env     = ENV.fetch('RACK_ENV', :development)
    db_name = ENV.fetch('DB_NAME', "smart_savings_#{env}")
    version = args[:version].to_i if args[:version]

    print "Running migrations on #{env} environment"
    begin
      connect(db_name) do |db|
        Sequel::Migrator.run(db, 'db/migrations', target: version)
      end
      puts ' - OK'
    rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError => e
      puts ' - FAIL'
      warn e.message
      abort 'Run `rake db:setup` to to kickstart the database'
    end
  end

  desc 'Load seed data from db/seeds.rb'
  task seed: :environment do
    next unless ENV['RACK_ENV'] == 'development' # only run if on dev env

    print 'Seeding data'
    begin
      seed_file = 'db/seeds.rb'
      load(seed_file) if File.exist?(seed_file)
      puts ' - OK'
    rescue => e
      puts ' - FAIL'
      abort e.message
    end
  end

  desc 'Setup database'
  task setup: %w[db:drop db:create db:migrate]
end
