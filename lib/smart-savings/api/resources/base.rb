# frozen_string_literal: true

require 'api/resources/users'
require 'api/resources/transactions'

module SmartSavings
  module API
    module Resources
      class Base < Grape::API # :nodoc:
        API_TOKEN = ENV['API_TOKEN']

        version :v1

        helpers do
          def declared_params
            declared(params, include_missing: false)
          end

          def render_errors(instance)
            error = instance.errors.full_messages.join(',')
            error!(error, 422)
          end
        end

        # GET /api/health
        desc 'Health check'
        get :health do
          payload = { message: 'ok' }
          present payload, with: Grape::Presenters::Presenter
        end

        rescue_from Sequel::NoMatchingRow do |e|
          error!({ error: "#{e.class} error", message: 'Not found' }, 404)
        end

        before do
          error!('Unauthorized', 401) unless headers['Api-Token'] == API_TOKEN
        end

        mount Users
        mount Transactions
      end
    end
  end
end
