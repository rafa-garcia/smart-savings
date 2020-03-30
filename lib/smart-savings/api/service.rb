# frozen_string_literal: true

require 'api/resources/base'

module SmartSavings
  module API
    class Service < Grape::API # :nodoc:
      format :json
      prefix :api

      # Support for CORS
      before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
      end

      helpers do
        # TODO: handle multiple versions of the same endpoint
        def build_path_map(endpoints)
          endpoints.each_with_object({}) do |endpoint, hash|
            route   = endpoint.routes.first
            path    = route.pattern.origin
            version = Array(route.version).shift
            name    = path.split('/').last + '_url'
            url     = path.sub(':version', version.to_s)

            hash[name] = url
          end
        end
      end

      # 404 on wrong endpoint
      route :any, '*path' do
        error!({ message: 'Endpoint not found', code: :not_found }, 404)
      end

      # GET /api
      desc 'API entry point'
      get do
        # root endpoint a la GitHub API
        present build_path_map(API::Resources::Base.endpoints)
      end

      mount API::Resources::Base
      add_swagger_documentation \
        doc_version: '1.0.0', info: { title: 'Smart Savings API' }
    end
  end
end
