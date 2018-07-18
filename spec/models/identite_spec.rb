require 'rails_helper'

describe Identite do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:pays_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:nationalite).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:identifiable) }

  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end
