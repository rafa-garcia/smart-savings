# frozen_string_literal: true

describe SmartSavings::Models::User do
  subject { SmartSavings::Models::User }

  let(:user) { subject.new(user_attributes) }

  describe '.new' do
    context 'when no arguments are given' do
      let(:user_attributes) { {} }

      it 'instantiates' do
        expect(user).to be_an_instance_of(subject)
      end

      it 'is a invalid instance' do
        expect(user.valid?).to be_falsey
      end
    end

    context 'when arguments are given' do
      context 'and they are invalid' do
        let(:user_attributes) { { name: 'name' } }

        it 'instantiates' do
          expect(user).to be_an_instance_of(subject)
        end

        it 'is a valid instance' do
          expect(user.valid?).to be_falsey
        end
      end

      context 'and they are valid' do
        let(:user_attributes) { { name: 'name', age: 42 } }

        it 'instantiates' do
          expect(user).to be_an_instance_of(subject)
        end

        it 'is a valid instance' do
          expect(user.valid?).to be_truthy
        end

        it 'has a name' do
          expect(user.name).to eq 'name'
        end

        it 'has an age' do
          expect(user.age).to eq 42
        end

        it 'has a balance of nil' do
          expect(user.balance).to eq nil
        end

        it 'has an empty collection of transactions' do
          expect(user.transactions).to eq []
        end
      end
    end
  end

  describe '#save' do
    let(:user_attributes) { { name: 'name', age: 42 } }

    it 'creates a new record' do
      expect { user.save }.to change { DB[:users].count }.from(0).to(1)
    end

    it 'sets the balance to zero' do
      expect { user.save }.to change { user.balance }.from(nil).to(0.0)
    end
  end

  describe '#update' do
    before { user.save }

    let(:user_attributes) { { name: 'name', age: 42 } }

    it 'does not create a new record' do
      expect(DB[:users].count).to eq 1
      user.update(name: 'name')
      expect(DB[:users].count).to eq 1
    end

    it 'updates the name' do
      user.update(name: 'another name')
      expect(user.name).to eq 'another name'
    end

    it 'updates the age' do
      user.update(age: 99)
      expect(user.age).to eq 99
    end
  end

  describe '#calculate_balance' do
    before do
      user.save
      transactions_attributes.each do |t|
        user.transactions << SmartSavings::Models::Transaction.create(t)
      end
    end

    let(:user_attributes) { { name: 'name', age: 42 } }
    let(:transactions_attributes) do
      [
        { user_id: user.id, amount: 44.0, type: 'debit' },
        { user_id: user.id, amount: 2.0, type: 'credit' }
      ]
    end

    it 'computes the balance' do
      expect(user.calculate_balance).to be 42.0
    end
  end

  describe '#net_income' do
    before do
      user.save
      transactions_attributes.each do |t|
        user.transactions << SmartSavings::Models::Transaction.create(t)
      end
    end

    let(:user_attributes) { { name: 'name', age: 42 } }
    let(:transactions_attributes) do
      [
        { user_id: user.id, amount: 42.0, type: 'debit' },
        { user_id: user.id, amount: 42.0, type: 'credit' }
      ]
    end

    it 'computes the net income' do
      expect(user.net_income).to be 42.0
    end
  end

  describe '#account_age_months' do
    before do
      user.save
      transactions_attributes.each do |t|
        user.transactions << SmartSavings::Models::Transaction.create(t)
      end
    end

    let(:user_attributes) { { name: 'name', age: 42 } }
    let(:transactions_attributes) do
      [
        { user_id: user.id, amount: 1.0, type: 'debit',
          created_at: '31-10-2016' },
        { user_id: user.id, amount: 1.0, type: 'credit',
          created_at: '13-04-2020' }
      ]
    end

    it 'calculates the span' do
      expect(user.account_age_months).to be 42.0
    end
  end

  describe '#update_balance!' do
    before do
      user.save
      transactions_attributes.each do |t|
        user.transactions << SmartSavings::Models::Transaction.create(t)
      end
    end

    let(:user_attributes) { { name: 'name', age: 42 } }
    let(:transactions_attributes) do
      [
        { user_id: user.id, amount: 44.0, type: 'debit' },
        { user_id: user.id, amount: 2.0, type: 'credit' }
      ]
    end

    it 'calculates the running total' do
      expect { user.update_balance! }
        .to change { user.balance }.from(0.0).to(42.0)
    end
  end
end
