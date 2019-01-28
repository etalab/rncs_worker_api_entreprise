require 'rails_helper'

describe TribunalInstance::AdresseDomiciliataireRepresenter, :representer do
  subject { entreprise_pm_representer.adresse_domiciliataire }

  it { is_expected.to be_a TribunalInstance::AdresseDomiciliataire }

  its(:ligne_1)         { is_expected.to be_nil }
  its(:residence)       { is_expected.to be_nil }
  its(:numero_voie)     { is_expected.to be_nil }
  its(:type_voie)       { is_expected.to be_nil }
  its(:nom_voie)        { is_expected.to be_nil }
  its(:code_postal)     { is_expected.to be_nil }
  its(:bureau_et_cedex) { is_expected.to be_nil }
end
