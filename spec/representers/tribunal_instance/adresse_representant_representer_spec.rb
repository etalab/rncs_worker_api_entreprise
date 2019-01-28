require 'rails_helper'

describe TribunalInstance::AdresseRepresentantRepresenter, :representer do
  subject do
    entreprise_pm_representer
      .representants
      .first
      .adresse_representant
  end

  it { is_expected.to be_a TribunalInstance::AdresseRepresentant }

  its(:residence)       { is_expected.to eq 'là bas' }
  its(:nom_voie)        { is_expected.to be_nil }
  its(:code_postal)     { is_expected.to be_nil }
  its(:localite)        { is_expected.to be_nil }
  its(:pays)            { is_expected.to be_nil }
end
