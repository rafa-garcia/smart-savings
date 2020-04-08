# frozen_string_literal: true

describe SmartSavings::Models::Transaction do
  subject { SmartSavings::Models::Transaction }

  let(:transaction) { subject.new(transaction_attributes) }
  let(:user) { SmartSavings::Models::User.create(name: 'name', age: 42) }

  describe '.new' do
    context 'when no arguments are given' do
      let(:transaction_attributes) { {} }

      it 'instantiates' do
        expect(transaction).to be_an_instance_of(subject)
      end

      it 'is a invalid instance' do
        expect(transaction.valid?).to be_falsey
      end
    end

    context 'when arguments are given' do
      context 'and they are invalid' do
        let(:transaction_attributes) { { amount: 0.0 } }

        it 'instantiates' do
          expect(transaction).to be_an_instance_of(subject)
        end

        it 'is a valid instance' do
          expect(transaction.valid?).to be_falsey
        end
      end

      context 'and they are valid' do
        let(:transaction_attributes) do
          { user_id: user.id, amount: 1.0, type: 'debit' }
        end

        it 'instantiates' do
          expect(transaction).to be_an_instance_of(subject)
        end

        it 'is a valid instance' do
          expect(transaction.valid?).to be_truthy
        end

        it 'has an amount' do
          expect(transaction.amount).to eq 1.0
        end

        it 'has a type' do
          expect(transaction.type).to eq 'debit'
        end

        it 'has a nil user' do
          expect(transaction.user)
            .to be_an_instance_of(SmartSavings::Models::User)
        end
      end
    end
  end

  describe '#save' do
    let(:transaction_attributes) do
      { user_id: user.id, amount: 1.0, type: 'debit' }
    end

    it 'creates a new record' do
      expect { transaction.save }
        .to change { DB[:transactions].count }.from(0).to(1)
    end

    it 'updates the balance of its user' do
      transaction.save
      expect { user.update_balance! }
        .to change { user.balance }.from(0.0).to(1.0)
    end

    context 'when the user has insufficient funds' do
      let(:transaction_attributes) do
        { user_id: user.id, amount: 1.0, type: 'credit' }
      end

      it 'raises an error' do
        expect { transaction.save }
          .to raise_error(Sequel::ValidationFailed, 'amount insufficient funds')
      end
    end
  end
end
