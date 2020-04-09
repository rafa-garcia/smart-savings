# frozen_string_literal: true

module SmartSavings
  module Models
    class User < Sequel::Model # :nodoc:
      Entity = Class.new(Grape::Entity) do # presenter class
        expose :id, :name, :age
        expose :formatted_balance, as: :balance
        expose :recommended_monthly_savings, expose_nil: false

        def formatted_balance
          object.balance.to_f.round(2)
        end
      end

      plugin :validation_helpers
      plugin :association_dependencies
      one_to_many :transactions
      add_association_dependencies transactions: :destroy

      # Number of months between a user's first and last transaction
      # (this should belong in an external query object, perhaps)
      def account_age_months
        transactions_dataset.select do
          (Sequel.function(
            :date_part, 'day', Sequel.lit('max(created_at) - min(created_at)')
          ) / 30).as(:interval_months)
        end.first.values[:interval_months]
      end

      # Summation of all positive transactions
      def net_income
        transactions_dataset.where(type: 'debit').sum(:amount)
      end

      # Difference of summations of credit and debit transaction amounts
      def calculate_balance
        transactions_dataset.sum(
          Sequel.case({ { type: 'credit' } => Sequel.*(:amount, -1) }, :amount)
        )
      end

      def update_balance!
        db.transaction do
          lock! # ensure no other process updates the record at the same time
          update(balance: calculate_balance)
        end
      end

      def update_savings_recommendation!
        return if account_age_months.to_f < 1.0

        db.transaction do
          lock!
          update(recommended_monthly_savings: Services::SavingsMeter.call(self))
        end
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
