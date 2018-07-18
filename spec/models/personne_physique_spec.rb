require 'rails_helper'

describe PersonnePhysique do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:activite_forain).of_type(:string) }
  it { is_expected.to have_db_column(:dap).of_type(:string) }
  it { is_expected.to have_db_column(:dap_denomination).of_type(:string) }
  it { is_expected.to have_db_column(:dap_objet).of_type(:string) }
  it { is_expected.to have_db_column(:dap_date_cloture).of_type(:string) }
  it { is_expected.to have_db_column(:eirl).of_type(:string) }
  it { is_expected.to have_db_column(:auto_entrepreneur).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collaborateur_date_fin).of_type(:string) }

  # Associations
  it { is_expected.to have_one(:identite) }
  it { is_expected.to have_one(:adresse) }
  it { is_expected.to have_one(:dap_adresse) }
  it { is_expected.to have_one(:conjoint_collaborateur_identite) }

  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end
