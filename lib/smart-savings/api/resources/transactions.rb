# frozen_string_literal: true

module SmartSavings
  module API
    module Resources
      class Transactions < Grape::API # :nodoc:
        helpers do
          def repository
            Models::Transaction
          end

          def find(id)
            repository.with_pk!(id)
          end
        end

        resource :transactions do
          # GET /api/v1/transactions
          desc 'Returns all transactions'
          get do
            present repository.all
          end

          # POST /api/v1/transactions
          desc 'Creates a transaction'
          params do
            requires :user_id, type: Integer, desc: 'User ID'
            requires :amount, type: Float, desc: 'Transaction amount'
            requires :type, values: %w[credit debit], desc: 'Transaction type'
          end
          post do
            instance = repository.new(declared_params)
            if instance.valid? && instance.save
              present instance
            else
              render_errors(instance)
            end
          end

          route_param :transaction_id do
            # GET /api/v1/transactions/:transaction_id
            desc 'Returns a single transaction'
            get do
              present find(params[:transaction_id])
            end

            # DELETE /api/v1/transactions/:transaction_id
            desc 'Deletes a transaction'
            delete do
              transaction = find(params[:transaction_id])
              if transaction.destroy
                status 204
              else
                render_errors(transaction)
              end
            end
          end
        end
      end
    end
  end
end
