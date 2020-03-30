# frozen_string_literal: true

module SmartSavings
  module API
    module Resources
      class Users < Grape::API # :nodoc:
        resource :users do
          # GET /api/v1/users
          desc 'Returns all users'
          get do
            present Models::User.all
          end

          route_param :user_id do
            # GET /api/v1/users/:user_id
            desc 'Returns a user'
            params do
              requires :user_id, type: Integer, desc: 'User id'
            end
            get do
              present Models::User.find(params[:user_id])
            end

            resource :transactions do
              # GET /api/v1/users/:user_id/transactions
              desc 'Returns all transactions of a user'
              get do
                present Models::User.find(params[:user_id]).transactions
              end
            end
          end
        end
      end
    end
  end
end
