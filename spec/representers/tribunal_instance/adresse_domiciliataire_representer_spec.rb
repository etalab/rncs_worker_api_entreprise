require 'rails_helper'

describe TribunalInstance::AdresseDomiciliataireRepresenter, :representer do
  subject { entreprise_pm_representer.adresse_domiciliataire }

  it { is_expected.to be_a TribunalInstance::AdresseDomiciliataire }

  its(:code_greffe)     { is_expected.to eq '9712' }
  its(:ligne_1)         { is_expected.to eq 'SOMEWHERE...' }
  its(:residence)       { is_expected.to eq 'RESIDENCE' }
  its(:numero_voie)     { is_expected.to eq 'INFINITE' }
  its(:type_voie)       { is_expected.to eq 'BANANA' }
  its(:nom_voie)        { is_expected.to eq 'VOIX' }
  its(:bureau_et_cedex) { is_expected.to eq 'BUREAU' }
end
