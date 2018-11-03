require 'rails_helper'

describe 'routes', type: :routing do
  it 'routes to pdf file' do
    expect(get("infos_identite_entreprise/#{valid_siren}/pdf")).to route_to(
      controller: 'api/infos_identite_entreprise',
      action: 'pdf',
      siren: valid_siren
    )
  end
end
