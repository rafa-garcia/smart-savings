# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../app', __dir__))

require File.expand_path('boot', __dir__)

SmartSavings::API::Root.configure do |config|
  config[:application_name] = 'Smart Savings API'
  config[:application_desc] = 'A service for crunching financial habits.'
end
