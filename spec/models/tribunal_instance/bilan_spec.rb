require 'rails_helper'

describe TribunalInstance::Bilan do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:date_cloture_annee).of_type(:string) }
  it { is_expected.to have_db_column(:date_cloture_jour_mois).of_type(:string) }
  it { is_expected.to have_db_column(:date_depot).of_type(:string) }
  it { is_expected.to have_db_column(:confidentialite_document_comptable).of_type(:string) }
  it { is_expected.to have_db_column(:confidentialite_compte_resultat).of_type(:string) }
  it { is_expected.to have_db_column(:numero).of_type(:string) }
  it { is_expected.to have_db_column(:duree_exercice).of_type(:string) }

  it { is_expected.to belong_to :entreprise }
end
