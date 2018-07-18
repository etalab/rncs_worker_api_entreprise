require 'rails_helper'

describe Adresse do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:ville).of_type(:string) }
  it { is_expected.to have_db_column(:code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:pays).of_type(:string) }
  it { is_expected.to have_db_column(:type).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:addressable) }

  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end
