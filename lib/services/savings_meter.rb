# frozen_string_literal: true

module SmartSavings
  module Services
    # SavingsMeter is a service object that takes a user and analyzes the
    # financial habits through their transactions, also factoring in
    # their age to work out an optimal savings amount.
    class SavingsMeter
      #
      # NOTES:
      # - Assuming income with monthly credits being [net_income]
      # - Assuming recurring expenses being [core_expenses]
      #
      #   [disposable_income] = [net_income] - [core_expenses]
      #
      # - Assuming linear interpolation [target_savings_rate] = Fx([age])
      #   WHERE [target_savings_rate] = 5% at [age] = 25
      #   AND [target_savings_rate] = 25% at [age] = 65
      #
      # - Therefore, to compute a [recommended_monthly_savings]:
      #
      #   [disposable_income] * [target_savings_rate] / 100
      #
      AGE_RANGE                  = (25..65).freeze
      TARGET_SAVINGS_RATES_RANGE = (5..25).freeze

      attr_reader :user

      def self.call(user)
        new(user).recommended_monthly_savings.to_i
      end

      def initialize(user)
        @user = user
      end

      def recommended_monthly_savings
        disposable_income * target_savings_rate / 100 / user.account_age_months
      end

      private

      # Linear interpolation between two adjacent rate values based on age
      def target_savings_rate
        max_age  = AGE_RANGE.max
        min_age  = AGE_RANGE.min
        max_rate = TARGET_SAVINGS_RATES_RANGE.max
        min_rate = TARGET_SAVINGS_RATES_RANGE.min
        age      = user.age.clamp(min_age, max_age) # normalizes age scalar

        ((max_rate * (age - min_age)) +
        (min_rate * (max_age - age))) / (max_age - min_age)
      end

      def net_income
        user.net_income.to_f
      end

      # Summation of all identified recurring transactions, averaged per month
      def core_expenses
        query = Queries::RecurringPaymentsFromUserId.new(user_id: user.id)
        query.relation.sum(:amount).to_f
      end

      def disposable_income
        return 0.0 if net_income <= core_expenses

        net_income - core_expenses
      end
    end
  end
end
