require 'rails_helper'

describe TribunalInstance::Etablissement do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:type_etablissement).of_type(:string) }
  it { is_expected.to have_db_column(:siret).of_type(:string) }
  it { is_expected.to have_db_column(:activite).of_type(:string) }
  it { is_expected.to have_db_column(:code_activite).of_type(:string) }
  it { is_expected.to have_db_column(:enseigne).of_type(:string) }
  it { is_expected.to have_db_column(:nom_commercial).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_activite).of_type(:string) }
  it { is_expected.to have_db_column(:origine_fonds).of_type(:string) }
  it { is_expected.to have_db_column(:type_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_cessation_activite).of_type(:string) }
  it { is_expected.to have_db_column(:type_exploitation).of_type(:string) }
  it { is_expected.to have_db_column(:precedent_exploitant_nom).of_type(:string) }
  it { is_expected.to have_db_column(:precedent_exploitant_nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:precedent_exploitant_prenom).of_type(:string) }

  # Associations
  it { is_expected.to have_one(:adresse).dependent(:destroy) }
  it { is_expected.to belong_to :entreprise }

  it_behaves_like 'having rails timestamps'

  describe 'adresse' do
    subject { create :titmc_etablissement }

    its(:adresse) { is_expected.to be_a TribunalInstance::AdresseEtablissement }
    its(:adresse) { is_expected.to have_attributes ligne_1: 'Ceci est une adresse d\'établissement' }

    its(:entreprise) { is_expected.to be_a TribunalInstance::Entreprise }
    its(:entreprise) { is_expected.to have_attributes forme_juridique: '9999' }
  end
end
