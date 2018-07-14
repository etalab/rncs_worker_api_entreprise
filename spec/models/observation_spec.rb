require 'rails_helper'

describe Observation do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:id_observation).of_type(:string) }
  it { is_expected.to have_db_column(:numero).of_type(:string) }
  it { is_expected.to have_db_column(:date_ajout).of_type(:string) }
  it { is_expected.to have_db_column(:date_suppression).of_type(:string) }
  it { is_expected.to have_db_column(:texte).of_type(:text) }
  it { is_expected.to have_db_column(:etat).of_type(:string) }

  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end
