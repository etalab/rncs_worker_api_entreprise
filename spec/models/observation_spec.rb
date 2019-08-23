require 'rails_helper'

describe Observation do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:id_observation).of_type(:string) }
  it { is_expected.to have_db_column(:numero).of_type(:string) }
  it { is_expected.to have_db_column(:date_ajout).of_type(:string) }
  it { is_expected.to have_db_column(:date_suppression).of_type(:string) }
  it { is_expected.to have_db_column(:texte).of_type(:text) }
  it { is_expected.to have_db_column(:etat).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:dossier_entreprise) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having rails timestamps'
  it_behaves_like 'having dossier greffe id'
  it_behaves_like '.import'
end
