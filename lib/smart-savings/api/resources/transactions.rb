# frozen_string_literal: true

module SmartSavings
  module API
    module Resources
      class Transactions < Grape::API # :nodoc:
        # GET /api/v1/transactions
        desc ''
        get :transactions do
          { message: 'ok' }
        end
      end
    end
  end
end
