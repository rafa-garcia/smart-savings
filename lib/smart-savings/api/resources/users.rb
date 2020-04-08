# frozen_string_literal: true

module SmartSavings
  module API
    module Resources
      class Users < Grape::API # :nodoc:
        helpers do
          def repository
            Models::User
          end

          def find(id)
            repository.with_pk!(id)
          end
        end

        resource :users do
          # GET /api/v1/users
          desc 'Returns all users'
          get do
            present repository.all
          end

          # POST /api/v1/users
          desc 'Creates a user'
          params do
            requires :age, type: Integer, desc: 'User age'
            requires :name, type: String, desc: 'User name'
          end
          post do
            instance = repository.new(declared_params)
            if instance.valid? && instance.save
              present instance
            else
              render_errors(instance)
            end
          end

          route_param :user_id do
            # GET /api/v1/users/:user_id
            desc 'Returns a single user'
            get do
              present find(params[:user_id])
            end

            # PUT /api/v1/users/:user_id
            desc 'Updates a user'
            params do
              optional :age, type: Integer, desc: 'User age'
              optional :name, type: String, desc: 'User name'
            end
            put do
              user = find(params[:user_id])
              if user.valid? && user.update(declared_params)
                present user
              else
                render_errors(user)
              end
            end

            # DELETE /api/v1/users
            desc 'Deletes a user'
            delete do
              user = find(params[:user_id])
              if user.destroy
                status 204
              else
                render_errors
              end
            end

            resource :transactions do
              # GET /api/v1/users/:user_id/transactions
              desc 'Returns all transactions of a user'
              get do
                present find(params[:user_id]).transactions
              end
            end
          end
        end
      end
    end
  end
end
