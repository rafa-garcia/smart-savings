# frozen_string_literal: true

module SmartSavings
  module Models
    class User < Sequel::Model # :nodoc:
      one_to_many :transactions

      def entity
        Entity.new(self)
      end

      class Entity < Grape::Entity # :nodoc:
        expose :id, :name, :age, :balance, :recommended_monthly_savings
      end
    end
  end
end
