require 'rails_helper'

describe TribunalInstance::AdresseSiegeRepresenter, :representer do
  subject { entreprise_pm_representer.adresse_siege }

  it { is_expected.to be_a TribunalInstance::AdresseSiege }

  its(:ligne_1)         { is_expected.to be_nil }
  its(:ligne_2)         { is_expected.to be_nil }
  its(:residence)       { is_expected.to be_nil }
  its(:numero_voie)     { is_expected.to be_nil }
  its(:type_voie)       { is_expected.to be_nil }
  its(:nom_voie)        { is_expected.to be_nil }
  its(:localite)        { is_expected.to be_nil }
  its(:code_postal)     { is_expected.to be_nil }
  its(:bureau_et_cedex) { is_expected.to be_nil }
  its(:pays)            { is_expected.to eq 'FR' }
end
