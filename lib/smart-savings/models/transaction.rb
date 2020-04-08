# frozen_string_literal: true

module SmartSavings
  module Models
    class Transaction < Sequel::Model # :nodoc:
      Entity = Class.new(Grape::Entity) do
        expose :id, :user_id, :amount, :type, :created_at
      end

      plugin :validation_helpers
      many_to_one :user

      private

      def after_create
        user.update_balance!
        super
      end

      def after_destroy
        user.update_balance!
        super
      end

      def amount_qualify?
        return type == 'debit' || amount < user.balance if user

        true
      end

      def validate
        super
        validates_presence %i[user_id amount type]
        validates_includes %w[credit debit], :type
        errors.add(:user_id, 'not found') unless user
        errors.add(:amount, 'insufficient funds') unless amount_qualify?
      end

      def entity
        Entity.new(self)
      end
    end
  end
end
