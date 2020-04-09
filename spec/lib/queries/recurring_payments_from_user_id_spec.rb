# frozen_string_literal: true

describe SmartSavings::Queries::RecurringPaymentsFromUserId do
  subject { SmartSavings::Queries::RecurringPaymentsFromUserId }

  let(:query) { subject.new(query_attributes) }
  let(:expected) do
  end

  describe '.new' do

    context 'when called with no arguments' do
      let(:query_attributes) { nil }

      it 'raises an error' do
        expect { query }.to raise_error(ArgumentError)
      end
    end

    context 'when called with an argument' do
      let(:query_attributes) { { user_id: 1 } }

      it 'instantiates' do
        expect(query).to be_an_instance_of(subject)
      end
    end
  end

  describe '#relation' do
    let(:query_attributes) { { user_id: 1 } }
    let(:expected_sql) do
      <<~SQL
        WITH "transactions_with_days_diff" AS (SELECT "amount", \
        row_number() OVER (PARTITION BY "amount"), date_part('day', \
        created_at - lag("created_at") OVER (PARTITION BY "amount" \
        ORDER BY "created_at")) AS "days_count" FROM "transactions" \
        WHERE (("user_id" = 1) AND ("type" = 'credit'))) SELECT * \
        FROM "transactions_with_days_diff" WHERE (days_count between 25 and 35)
      SQL
    end

    it 'builds a query' do
      expect(query.relation.sql).to eq(expected_sql.chomp)
    end
  end
end
