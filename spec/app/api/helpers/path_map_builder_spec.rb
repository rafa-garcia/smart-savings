# frozen_string_literal: true

describe SmartSavings::API::Helpers::PathMapBuilder do
  include SmartSavings::API::Helpers::PathMapBuilder

  let(:api) { double Grape::API }
  let(:root_route) { { path: '/api(.json)', version: nil } }
  let(:health_route) { { path: '/api/:version/health(.json)', version: 'v1' } }
  let(:doc_route) { { path: '/api/swagger_doc(.:format)', version: nil } }
  let(:routes) do
    [
      double(Grape::Router::Route, root_route),
      double(Grape::Router::Route, health_route),
      double(Grape::Router::Route, doc_route)
    ]
  end
  let(:expected) do
    {
      'api_url' => '/api',
      'health_url' => '/api/v1/health',
      'swagger_doc_url' => '/api/swagger_doc'
    }
  end

  describe '.build_path_map' do
    before do
      expect(api).to receive(:routes).and_return(routes)
    end

    it 'returns a hash of paths' do
      expect(build_path_map(api)).to eq(expected)
    end
  end
end
