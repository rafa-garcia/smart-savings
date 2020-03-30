# frozen_string_literal: true

module SmartSavings
  module Models
    class Transaction < Sequel::Model # :nodoc:
      many_to_one :user

      def entity
        Entity.new(self)
      end

      class Entity < Grape::Entity # :nodoc:
        expose :id, :user_id, :amount, :type, :created_at
      end
    end
  end
end
