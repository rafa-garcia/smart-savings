# frozen_string_literal: true

describe SmartSavings::API::Resources::Users do
  include Rack::Test::Methods

  def app
    SmartSavings::API::Resources::Base
  end

  let(:parsed_response) { JSON.parse(last_response.body) }
  let(:model) { SmartSavings::Models::User }
  let(:user) { { id: 1, name: 'name', age: 42 } }

  describe 'GET /api/v1/users' do
    before { expect(model).to receive(:all).and_return(users) }

    context 'when there are no users' do
      let(:users) { [] }

      it 'returns 200' do
        get '/api/v1/users'
        expect(last_response.status).to eq 200
      end

      it 'returns an empty collection' do
        get '/api/v1/users'
        expect(parsed_response).to be_empty
      end
    end

    context 'when there are users' do
      let(:users) { [{ id: 1, name: 'alice' }, { id: 2, name: 'bob' }] }

      it 'returns 200' do
        get '/api/v1/users'
        expect(last_response.status).to eq 200
      end

      it 'returns a collection of users' do
        get '/api/v1/users'
        expect(parsed_response).to be_an(Array)
        expect(parsed_response.size).to eq(2)
        expect(parsed_response).to all(include('name'))
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'when the params are invalid' do
      it 'returns 400' do
        post '/api/v1/users', {}
        expect(last_response.status).to eq 400
      end
    end

    context 'when the params are valid' do
      let(:params) { { name: 'name', age: 42 } }

      it 'creates a user' do
        expect(model).to receive(:new).and_return(user)
        expect(user).to receive(:valid?).and_return(true)
        expect(user).to receive(:save).and_return(true)
        post '/api/v1/users', params
        expect(last_response.status).to eq 201
      end
    end
  end

  describe 'GET /api/v1/users/:user_id' do
    context 'when the user does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        get '/api/v1/users/42'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the user exists' do
      before { expect(model).to receive(:with_pk!).and_return(user) }

      it 'returns 200' do
        get '/api/v1/users/1'
        expect(last_response.status).to eq 200
      end

      it 'returns the user' do
        get '/api/v1/users/1'
        expect(parsed_response).to be_a(Hash)
        expect(parsed_response).to include('id')
        expect(parsed_response).to include('name')
        expect(parsed_response).to include('age')
      end
    end
  end

  describe 'PUT /api/v1/users/:user_id' do
    context 'when the user does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        put '/api/v1/users/42'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the user exists' do
      before do
        expect(model).to receive(:with_pk!).and_return(user)
        expect(user).to receive(:valid?).and_return(true)
        expect(user).to receive(:update).and_return(true)
      end

      context 'and the params are valid' do
        let(:params) {}
        it 'returns 200' do
          put '/api/v1/users/1'
          expect(last_response.status).to eq 200
        end

        it 'updates the user' do
          put '/api/v1/users/1'
          expect(parsed_response).to be_a(Hash)
          expect(parsed_response).to include('id')
          expect(parsed_response).to include('name')
          expect(parsed_response).to include('age')
        end
      end
    end
  end

  describe 'DELETE /api/v1/users/:user_id' do
    context 'when the user does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        delete '/api/v1/users/42'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the user exists' do
      it 'returns 204' do
        expect(model).to receive(:with_pk!).and_return(user)
        expect(user).to receive(:destroy).and_return(true)
        delete '/api/v1/users/1'
        expect(last_response.status).to eq 204
      end
    end
  end

  describe 'GET /api/v1/users/:user_id/transactions' do
    context 'when the user does not exist' do
      it 'returns 404' do
        expect(model).to receive(:with_pk!).and_raise(Sequel::NoMatchingRow)
        get '/api/v1/users/42/transactions'
        expect(last_response.status).to eq 404
      end
    end

    context 'when the user exists' do
      before do
        expect(model).to receive(:with_pk!).and_return(user)
        expect(user).to receive(:transactions).and_return([])
      end

      it 'returns 200' do
        get '/api/v1/users/1/transactions'
        expect(last_response.status).to eq 200
      end

      it 'returns all transactions of the user' do
        get '/api/v1/users/1/transactions'
        expect(parsed_response).to be_an(Array)
      end
    end
  end
end
