# frozen_string_literal: true

describe SmartSavings::API::Resources::Users do
  include Rack::Test::Methods

  def app
    SmartSavings::API::Resources::Base
  end

  let(:parsed_response) { JSON.parse(last_response.body) }
  let(:users) { [{ name: 'alice' }, { name: 'bob' }] }

  describe 'GET /api/v1/users' do
    context 'when there are no users' do
      let(:users) { [] }

      it 'returns 200' do
        get '/api/v1/users'
        expect(last_response.status).to eq 200
      end

      it 'returns an empty collection' do
        expect(SmartSavings::Models::User).to receive(:all).and_return(users)
        get '/api/v1/users'
        expect(parsed_response).to be_empty
      end
    end

    context 'when there are users' do
      it 'returns 200' do
        expect(SmartSavings::Models::User).to receive(:all).and_return(users)
        get '/api/v1/users'
        expect(last_response.status).to eq 200
      end

      it 'returns a collection of users' do
        expect(SmartSavings::Models::User).to receive(:all).and_return(users)
        get '/api/v1/users'
        expect(parsed_response).to be_an(Array)
        expect(parsed_response.size).to eq(2)
        expect(parsed_response).to all(include('name'))
      end
    end
  end
end
