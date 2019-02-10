require 'rails_helper'

describe TribunalInstance::Acte do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:type_acte).of_type(:string) }
  it { is_expected.to have_db_column(:nature).of_type(:string) }
  it { is_expected.to have_db_column(:date_depot).of_type(:string) }
  it { is_expected.to have_db_column(:date_acte).of_type(:string) }
  it { is_expected.to have_db_column(:numero_depot_manuel).of_type(:string) }

  it { is_expected.to belong_to :entreprise }
end
