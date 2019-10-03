require 'rails_helper'

describe TribunalInstance::Representant do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:qualite).of_type(:string) }
  it { is_expected.to have_db_column(:raison_sociale_ou_nom_ou_prenom).of_type(:string) }
  it { is_expected.to have_db_column(:nom_ou_denomination).of_type(:string) }
  it { is_expected.to have_db_column(:prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:type_representant).of_type(:string) }
  it { is_expected.to have_db_column(:date_creation).of_type(:string) }
  it { is_expected.to have_db_column(:date_modification).of_type(:string) }
  it { is_expected.to have_db_column(:date_radiation).of_type(:string) }
  it { is_expected.to have_db_column(:pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:pays_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:nationalite).of_type(:string) }
  it { is_expected.to have_db_column(:nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:greffe_immatriculation).of_type(:string) }
  it { is_expected.to have_db_column(:siren_ou_numero_gestion).of_type(:string) }
  it { is_expected.to have_db_column(:forme_juridique).of_type(:string) }
  it { is_expected.to have_db_column(:commentaire).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_nom).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_pays_naissance).of_type(:string) }

  it_behaves_like 'having rails timestamps'

  # Associations
  it { is_expected.to belong_to :entreprise }
  it { is_expected.to have_one(:adresse_representant).dependent(:destroy) }
  it { is_expected.to have_one(:adresse_representant_permanent).dependent(:destroy) }

  describe 'representant' do
    subject { create :titmc_representant }

    its(:entreprise) { is_expected.to be_a TribunalInstance::Entreprise }
    its(:entreprise) { is_expected.to have_attributes forme_juridique: '9999' }

    its(:adresse_representant) { is_expected.to be_a TribunalInstance::AdresseRepresentant }
    its(:adresse_representant) { is_expected.to have_attributes(ligne_1: 'Ceci est une adresse de représentant') }

    its(:adresse_representant_permanent) { is_expected.to be_a TribunalInstance::AdresseRepresentantPermanent }
    its(:adresse_representant_permanent) do
      is_expected.to have_attributes(ligne_1: 'Ceci est une adresse de représentant permanent')
    end
  end
end
