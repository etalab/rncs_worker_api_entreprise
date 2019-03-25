require 'rails_helper'

describe 'Cors requests', type: :request do
  it 'uses rack cors middleware' do
    expect(Rails.application.middleware.middlewares).to include(Rack::Cors)
  end

  # More on testing cors policy : http://jbilbo.com/blog/2015/05/19/testing-cors-with-rspec/
  it 'allows any origin for /api/infos_identite_entreprise_rncs' do
    get "/v1/infos_identite_entreprise/#{valid_siren}", headers: { 'HTTP_ORIGIN': '*' }

    expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
  end
end
