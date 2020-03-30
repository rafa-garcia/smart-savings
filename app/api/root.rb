# frozen_string_literal: true

require 'api/endpoints/base'
require 'api/helpers/path_map_builder'

module SmartSavings
  module API
    class Root < Grape::API # :nodoc:
      helpers Helpers::PathMapBuilder

      format :json
      prefix :api

      # Support for CORS
      before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
      end

      # GET /api
      desc 'API entry point'
      get do
        build_path_map(API::Base) # root endpoint a la GitHub API
      end

      mount API::Base
      add_swagger_documentation \
        doc_version: '1.0.0',
        info: { title: 'Smart Savings API' }
    end
  end
end
