require 'rails_helper'

describe TribunalInstance::AdresseRepresentantPermanentRepresenter, :representer do
  subject do
    entreprise_greffe_secondaire
      .representants[1]
      .adresse_representant_permanent
  end

  it { is_expected.to be_a TribunalInstance::AdresseRepresentantPermanent }

  its(:ligne_1) { is_expected.to eq 'tout là bas' }
end
