# frozen_string_literal: true

describe SmartSavings::API::Base do
  include Rack::Test::Methods

  def app
    SmartSavings::API::Base
  end

  let(:parsed_response) { JSON.parse(last_response.body) }
  let(:health_check) { { 'message' => 'ok' } }

  describe 'GET /api/v1/health' do
    it 'returns 200' do
      get '/api/v1/health'
      expect(last_response.status).to eq 200
    end

    it 'returns ok' do
      get '/api/v1/health'
      expect(parsed_response['message']).to eq 'ok'
    end
  end
end
