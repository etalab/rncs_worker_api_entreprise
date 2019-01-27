require 'rails_helper'

describe TribunalInstance::Adresse do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:type).of_type(:string) }
  it { is_expected.to have_db_column(:ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:residence).of_type(:string) }
  it { is_expected.to have_db_column(:numero_voie).of_type(:string) }
  it { is_expected.to have_db_column(:type_voie).of_type(:string) }
  it { is_expected.to have_db_column(:nom_voie).of_type(:string) }
  it { is_expected.to have_db_column(:localite).of_type(:string) }
  it { is_expected.to have_db_column(:code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:bureau_et_cedex).of_type(:string) }
  it { is_expected.to have_db_column(:pays).of_type(:string) }

  it_behaves_like 'having rails timestamps'
end
