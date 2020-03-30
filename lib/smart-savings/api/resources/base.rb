# frozen_string_literal: true

require 'api/resources/users'
require 'api/resources/transactions'

module SmartSavings
  module API
    module Resources
      class Base < Grape::API # :nodoc:
        version :v1

        # GET /api/health
        desc 'Health check'
        get :health do
          payload = { message: 'ok' }
          present payload, with: Grape::Presenters::Presenter
        end

        mount Users
        mount Transactions
      end
    end
  end
end
