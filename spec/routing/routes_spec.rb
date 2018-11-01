require 'rails_helper'

describe 'routes', type: :routing do
  it 'route to pdf file' do
    expect(get("/api/pdf/#{valid_siren}")).to route_to(controller: 'api/pdf', action: 'show', siren: valid_siren)
  end
end
