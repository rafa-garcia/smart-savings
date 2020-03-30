# frozen_string_literal: true

describe SmartSavings::API::Root do
  include Rack::Test::Methods

  def app
    SmartSavings::API::Root
  end

  let(:parsed_response) { JSON.parse(last_response.body) }
  let(:path_map) { { 'health_url' => '/api/v1/health' } }

  context 'when the endpoint is invalid' do
    describe 'GET /api/invalid' do
      it 'returns 404' do
        get '/api/invalid'
        expect(last_response.status).to eq 404
      end

      it 'returns an error code' do
        get '/api/invalid'
        expect(parsed_response['code']).to eq 'not_found'
      end

      it 'returns an error message' do
        get '/api/invalid'
        expect(parsed_response['message']).to eq 'Endpoint not found'
      end

      it 'supports CORS' do
        get '/api/invalid'
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Request-Method']).to eq '*'
      end
    end
  end

  context 'when the endpoint is valid' do
    describe 'GET /api' do
      it 'returns 200' do
        get '/api'
        expect(last_response.status).to eq 200
      end

      it 'returns path map' do
        get '/api'
        expect(parsed_response).to eq path_map
      end

      it 'supports CORS' do
        get '/api'
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Request-Method']).to eq '*'
      end
    end

    describe 'GET /api/swagger_doc' do
      it 'returns 200' do
        get '/api/swagger_doc'
        expect(last_response.status).to eq 200
      end

      it 'returns swagger doc' do
        get '/api/swagger_doc'
        expect(parsed_response['swagger']).to eq '2.0'
      end
    end
  end
end
