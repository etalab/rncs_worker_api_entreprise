require 'rails_helper'

describe TribunalInstance::AdresseRepresentantPermanentRepresenter, :representer do
  subject do
    entreprise_greffe_0000
      .representants[1]
      .adresse_representant_permanent
  end

  it { is_expected.to be_a(TribunalInstance::AdresseRepresentantPermanent) }

  its(:code_greffe) { is_expected.to eq('0000') }
  its(:ligne_1)     { is_expected.to eq('tout là bas') }
end
