require 'rails_helper'

describe TribunalInstance::Entreprise do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:siren).of_type(:string) }
  it { is_expected.to have_db_column(:numero_gestion).of_type(:string) }
  it { is_expected.to have_db_column(:denomination).of_type(:string) }
  it { is_expected.to have_db_column(:nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:forme_juridique).of_type(:string) }
  it { is_expected.to have_db_column(:associe_unique).of_type(:string) }
  it { is_expected.to have_db_column(:date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:code_activite).of_type(:string) }
  it { is_expected.to have_db_column(:activite_principale).of_type(:string) }
  it { is_expected.to have_db_column(:capital).of_type(:string) }
  it { is_expected.to have_db_column(:devise).of_type(:string) }
  it { is_expected.to have_db_column(:capital_actuel).of_type(:string) }
  it { is_expected.to have_db_column(:duree_pm).of_type(:string) }
  it { is_expected.to have_db_column(:date_cloture).of_type(:string) }
  it { is_expected.to have_db_column(:nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:sigle).of_type(:string) }
  it { is_expected.to have_db_column(:nom_commercial).of_type(:string) }
  it { is_expected.to have_db_column(:greffe_siege).of_type(:string) }
  it { is_expected.to have_db_column(:statut_edition_extrait).of_type(:string) }
  it { is_expected.to have_db_column(:date_cloture_exceptionnelle).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_nom).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_rcs).of_type(:string) }
  it { is_expected.to have_db_column(:eirl).of_type(:string) }
  it { is_expected.to have_db_column(:dap_denomnimation).of_type(:string) }
  it { is_expected.to have_db_column(:dap_object).of_type(:string) }
  it { is_expected.to have_db_column(:dap_date_cloture).of_type(:string) }
  it { is_expected.to have_db_column(:auto_entrepreneur).of_type(:string) }
  it { is_expected.to have_db_column(:economie_sociale_solidaire).of_type(:string) }
  it { is_expected.to have_db_column(:dossier_entreprise_id).of_type(:string) }

  # Associations
  it { is_expected.to belong_to :dossier_entreprise }
  it { is_expected.to have_one(:adresse_siege).dependent(:destroy) }
  it { is_expected.to have_one(:adresse_domiciliataire).dependent(:destroy) }
  it { is_expected.to have_one(:adresse_dap).dependent(:destroy) }
  it { is_expected.to have_many(:etablissements).dependent(:destroy) }
  it { is_expected.to have_many(:representants).dependent(:destroy) }
  it { is_expected.to have_many(:observations).dependent(:destroy) }
  it { is_expected.to have_many(:actes).dependent(:destroy) }
  it { is_expected.to have_many(:bilans).dependent(:destroy) }

  describe 'dossier TITMC' do
    subject { create :titmc_entreprise }

    its(:adresse_siege) { is_expected.to be_a TribunalInstance::AdresseSiege }
    its(:adresse_siege) { is_expected.to have_attributes ligne_1: 'Ceci est une adresse de siège' }

    its(:adresse_domiciliataire) { is_expected.to be_a TribunalInstance::AdresseDomiciliataire }
    its(:adresse_domiciliataire) { is_expected.to have_attributes ligne_1: 'Ceci est l adresse du domiciliataire' }

    its(:adresse_dap) { is_expected.to be_a TribunalInstance::AdresseDAP }
    its(:adresse_dap) { is_expected.to have_attributes residence: 'Ceci est une résidence DAP' }

    its(:etablissements) { are_expected.to all be_a TribunalInstance::Etablissement }
    its(:etablissements) { are_expected.to all have_attributes precedent_exploitant_nom: 'me' }

    its(:representants) { are_expected.to all be_a TribunalInstance::Representant }
    its(:representants) { are_expected.to all have_attributes type_representant: 'PM' }
  end

  it_behaves_like 'having rails timestamps'
end
