# frozen_string_literal: true

module SmartSavings
  module API
    class Base < Grape::API # :nodoc:
      version :v1

      # GET /api/v1/health
      desc 'Health check'
      get :health do
        { message: 'ok' }
      end
    end
  end
end
