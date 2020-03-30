# frozen_string_literal: true

module SmartSavings
  module API
    module Helpers
      # PathMapBuilder constructs a hash with the API endpoint names and their
      # relative paths out of a Grape::API instance and its nested mounts.
      module PathMapBuilder
        PathEntry = Struct.new(:path) do
          attr_reader :path, :name, :url

          def initialize(path)
            @path = path
            normalize_path
          end

          def name
            @name ||= path.split('/').last + '_url' # e.g. 'health_url'
          end

          def url(version = nil)
            @url ||= @path.sub('{version}', version.to_s)
          end

          private

          def normalize_path
            @path = path.sub(/\(\.:?\w+?\)$/, '') # remove format e.g. '(.json)'
                        .gsub(/:(\w+)/, '{\1}')   # path params in curly braces
          end
        end

        def build_path_map(endpoint)
          endpoint.routes.each_with_object({}) do |route, hash|
            path    = PathEntry.new(route.path.dup)
            version = Array(route.version).shift

            hash[path.name] = path.url(version)
          end
        end
      end
    end
  end
end
