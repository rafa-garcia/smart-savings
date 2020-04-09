# frozen_string_literal: true

module SmartSavings
  module Queries
    # RecurringPaymentsFromUserId is a query object that detects current
    # recurring payments through analysing their EXACT amount across a user's
    # history of transactions on a gap of 25-35 days between them.
    class RecurringPaymentsFromUserId
      #
      # NOTES:
      # This object builds the following query when given a [user_id]:
      #
      # WITH transactions_with_day_diff AS (
      #   SELECT
      #     ROW_NUMBER() OVER (PARTITION BY amount),
      #     DATE_PART('day',
      #     created_at - (LAG(created_at) OVER (PARTITION BY amount ORDER BY created_at))) AS days_count,
      #     *
      #   FROM
      #     transactions
      #   WHERE
      #     user_id = [user_id]
      #     AND "type" = 'credit'
      # )
      # SELECT
      #   *
      # FROM
      #   transactions_with_day_diff
      # WHERE
      #   AND days_count BETWEEN 25 AND 35;
      #
      def initialize(user_id:)
        @user_id = user_id
      end

      def relation
        DB[:transactions]
          .with(:transactions_with_days_diff, transactions_with_day_diff(ddate))
          .from(:transactions_with_days_diff)
          .where { Sequel.lit('days_count between ? and ?', 25, 35) }
      end

      private

      # Dataset representing a user's credit transactions with number of days
      # passed since the previous transaction of the same amount
      def transactions_with_day_diff(diff_days)
        DB[:transactions]
          .where(user_id: @user_id, type: 'credit')
          .select(:amount)
          .select_append(
            Sequel.function(:row_number).over(partition: :amount), diff_days
          )
      end

      # Diff between current and previous transactions' dates measured in days
      def ddate
        Sequel.function(:date_part, 'day', Sequel.lit('created_at - ?', pdate))
              .as(:days_count)
      end

      # Previous transaction's date
      def pdate
        Sequel.function(:lag, :created_at)
              .over(partition: :amount, order: :created_at)
      end
    end
  end
end
