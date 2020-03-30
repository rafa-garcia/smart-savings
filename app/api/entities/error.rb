# frozen_string_literal: true

module SmartSavings
  module API
    class Error < Grape::Entity # :nodoc:
      expose :code
      expose :message
    end
  end
end
