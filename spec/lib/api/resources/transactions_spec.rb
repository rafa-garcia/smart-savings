# frozen_string_literal: true

describe SmartSavings::API::Resources::Users do
  include Rack::Test::Methods

  def app
    SmartSavings::API::Resources::Base
  end

  let(:parsed_response) { JSON.parse(last_response.body) }
  let(:model) { SmartSavings::Models::Transaction }
  let(:transaction) { { id: 1, user_id: 1, amount: 1.0, type: 'debit' } }
  let(:errors) { [] }

  describe 'GET /api/v1/transactions' do
    before { expect(model).to receive(:all).and_return(transactions) }

    context 'when there are no transactions' do
      let(:transactions) { [] }

      it 'returns 200' do
        get '/api/v1/transactions'
        expect(last_response.status).to eq 200
      end

      it 'returns an empty collection' do
        get '/api/v1/transactions'
        expect(parsed_response).to be_empty
      end
    end

    context 'when there are transactions' do
      let(:transactions) do
        [transaction, { id: 2, user_id: 1, amount: 1.0, type: 'credit' }]
      end

      it 'returns 200' do
        get '/api/v1/transactions'
        expect(last_response.status).to eq 200
      end

      it 'returns an empty collection' do
        get '/api/v1/transactions'
        expect(parsed_response).to be_an(Array)
        expect(parsed_response.size).to eq(2)
        expect(parsed_response).to all(include('amount'))
        expect(parsed_response).to all(include('type'))
      end
    end
  end

  describe 'POST /api/v1/transactions' do
    context 'when the params are invalid' do
      it 'returns 400' do
        post '/api/v1/transactions', {}
        expect(last_response.status).to eq 400
      end
    end

    context 'when the params are valid' do
      let(:params) { { user_id: 1, amount: 1.0, type: 'debit' } }

      it 'creates a transaction' do
        expect(model).to receive(:new).and_return(transaction)
        expect(transaction).to receive(:valid?).and_return(true)
        expect(transaction).to receive(:save).and_return(true)
        post '/api/v1/transactions', params
        expect(last_response.status).to eq 201
      end
    end
  end

  describe 'GET /api/v1/transactions/:transaction_id' do
    context 'when the transaction does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        get '/api/v1/transactions/42'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the transaction exists' do
      before { expect(model).to receive(:with_pk!).and_return(transaction) }

      it 'returns 200' do
        get '/api/v1/transactions/1'
        expect(last_response.status).to eq 200
      end

      it 'returns the transaction' do
        get '/api/v1/transactions/1'
        expect(parsed_response).to be_a(Hash)
        expect(parsed_response).to include('id')
        expect(parsed_response).to include('user_id')
        expect(parsed_response).to include('amount')
        expect(parsed_response).to include('type')
      end
    end
  end

  describe 'DELETE /api/v1/transactions/:transaction_id' do
    context 'when the transaction does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        delete '/api/v1/transactions/42'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the transaction exists' do
      it 'returns 204' do
        expect(model).to receive(:with_pk!).and_return(transaction)
        expect(transaction).to receive(:destroy).and_return(true)
        delete '/api/v1/transactions/1'
        expect(last_response.status).to eq 204
      end
    end
  end
end
