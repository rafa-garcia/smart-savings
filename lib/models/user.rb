# frozen_string_literal: true

module SmartSavings
  module Models
    class User < Sequel::Model # :nodoc:
      Entity = Class.new(Grape::Entity) do # presenter class
        expose :id, :name, :age
        expose :formatted_balance, as: :balance
        expose :recommended_monthly_savings, expose_nil: false

        def formatted_balance
          object.balance.round(2)
        end
      end

      plugin :validation_helpers
      plugin :association_dependencies
      one_to_many :transactions
      add_association_dependencies transactions: :destroy

      def update_balance!
        new_balance = debit_amount - credit_amount
        db.transaction do # preventing deadlock conditions
          lock!
          update(balance: new_balance)
        end
      end

      def update_savings_recommendation!
        # update(recommended_monthly_savings: SavingsMeter.call(self))
        'not yet implemented'
      end

      def debit_amount
        transactions_dataset.where(type: 'debit').sum(:amount).to_f
      end

      def credit_amount
        transactions_dataset.where(type: 'credit').sum(:amount).to_f
      end

      private

      def validate
        super
        validates_presence %i[name age]
      end

      def entity
        Entity.new(self)
      end
    end
  end
end
