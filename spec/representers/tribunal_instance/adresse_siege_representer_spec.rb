require 'rails_helper'

describe TribunalInstance::AdresseSiegeRepresenter, :representer do
  subject { entreprise_pm_representer.adresse_siege }

  it { is_expected.to be_a TribunalInstance::AdresseSiege }

  its(:ligne_1)         { is_expected.to eq 'NOM UN' }
  its(:ligne_2)         { is_expected.to eq 'NOM DEUX' }
  its(:residence)       { is_expected.to eq 'RESIDENCE' }
  its(:numero_voie)     { is_expected.to eq 'INFINITE' }
  its(:type_voie)       { is_expected.to eq 'BANANA' }
  its(:nom_voie)        { is_expected.to eq 'VOIX' }
  its(:localite)        { is_expected.to eq 'THE MOON' }
  its(:code_postal)     { is_expected.to eq 'A LOT' }
  its(:bureau_et_cedex) { is_expected.to eq 'BUREAU' }
  its(:pays)            { is_expected.to eq 'FR' }
end
