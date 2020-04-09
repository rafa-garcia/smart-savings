# frozen_string_literal: true

describe SmartSavings::Services::SavingsMeter do
  subject { SmartSavings::Services::SavingsMeter }

  let(:user) { SmartSavings::Models::User.new(user_attributes) }
  let(:transactions_attributes) do
    [
      { user_id: user.id, amount: 1000.0, type: 'debit',
        created_at: '01-01-2020' },
      { user_id: user.id, amount: 10.0, type: 'credit',
        created_at: '10-01-2020' },
      { user_id: user.id, amount: 600.0, type: 'credit',
        created_at: '15-01-2020' },
      { user_id: user.id, amount: 1000.0, type: 'debit',
        created_at: '01-02-2020' },
      { user_id: user.id, amount: 600.0, type: 'credit',
        created_at: '15-02-2020' },
      { user_id: user.id, amount: 15.0, type: 'credit',
        created_at: '20-02-2020' },
      { user_id: user.id, amount: 1000.0, type: 'debit',
        created_at: '01-03-2020' },
      { user_id: user.id, amount: 600.0, type: 'credit',
        created_at: '15-03-2020' },
      { user_id: user.id, amount: 20.0, type: 'credit',
        created_at: '30-03-2020' }
    ]
  end

  describe '.call' do
    context 'when called with no arguments' do
      it 'raises an error' do
        expect { subject.call }.to raise_error ArgumentError
      end
    end

    context 'when called with a user as argument' do
      before do
        user.save
        transactions_attributes.each do |t|
          user.transactions << SmartSavings::Models::Transaction.create(t)
        end
      end

      context 'and the user is 25' do
        let(:user_attributes) { { name: 'name surname', age: 25 } }

        it 'returns a recommended savings amount' do
          expect(subject.call(user)).to eq 30
        end
      end

      context 'and the user is 65' do
        let(:user_attributes) { { name: 'name surname', age: 65 } }

        it 'returns a recommended savings amount' do
          expect(subject.call(user)).to eq 151
        end
      end
    end
  end
end
