require 'rails_helper'

describe TribunalInstance::AdresseDAPRepresenter, :representer do
  subject { entreprise_pp_representer.adresse_dap }

  it { is_expected.to be_a TribunalInstance::AdresseDAP }

  its(:residence)       { is_expected.to eq 'RESIDENCE' }
  its(:numero_voie)     { is_expected.to eq 'INFINITE' }
  its(:type_voie)       { is_expected.to eq 'BANANA' }
  its(:nom_voie)        { is_expected.to eq '24 RUE DES ROSSIGNOLS' }
  its(:localite)        { is_expected.to eq 'THE MOON' }
  its(:code_postal)     { is_expected.to eq '68500' }
  its(:bureau_et_cedex) { is_expected.to eq 'ISSENHEIM' }
  its(:pays)            { is_expected.to eq 'NO COUNTRY FOR OLD MEN' }
end
