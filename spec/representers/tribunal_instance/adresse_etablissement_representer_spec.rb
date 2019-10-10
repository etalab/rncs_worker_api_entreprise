require 'rails_helper'

describe TribunalInstance::AdresseEtablissementRepresenter, :representer do
  subject { etablissement_representer.adresse }

  it { is_expected.to be_a(TribunalInstance::AdresseEtablissement) }

  its(:code_greffe)     { is_expected.to eq('9712') }
  its(:ligne_1)         { is_expected.to eq('PARTIE UN') }
  its(:ligne_2)         { is_expected.to eq('PARTIE DEUX') }
  its(:residence)       { is_expected.to eq('RESIDENCE') }
  its(:nom_voie)        { is_expected.to eq('67 RUE ARMAND BARBES') }
  its(:localite)        { is_expected.to eq('THE MOON') }
  its(:code_postal)     { is_expected.to eq('97110 POINTE A PITRE') }
end
