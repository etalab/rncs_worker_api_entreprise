require 'rails_helper'

describe DossierEntreprise do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:nom_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:type_inscription).of_type(:string) }
  it { is_expected.to have_db_column(:date_immatriculation).of_type(:string) }
  it { is_expected.to have_db_column(:date_premiere_immatriculation).of_type(:string) }
  it { is_expected.to have_db_column(:date_radiation).of_type(:string) }
  it { is_expected.to have_db_column(:date_transfert).of_type(:string) }
  it { is_expected.to have_db_column(:sans_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_premiere_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_cessation_activite).of_type(:string) }
  it { is_expected.to have_db_column(:numero_rcs).of_type(:string) }
  it { is_expected.to have_db_column(:code_radiation).of_type(:string) }
  it { is_expected.to have_db_column(:motif_radiation).of_type(:string) }

  # Associations TC
  it { is_expected.to have_one(:personne_morale).dependent(:destroy) }
  it { is_expected.to have_one(:personne_physique).dependent(:destroy) }
  it { is_expected.to have_many(:representants).dependent(:destroy) }
  it { is_expected.to have_many(:observations).dependent(:destroy) }
  it { is_expected.to have_many(:etablissements).dependent(:destroy) }
  # Associations TITMC
  it { is_expected.to have_one(:titmc_entreprise).dependent(:destroy) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having dossier greffe id'
  it_behaves_like 'having rails timestamps'

  let(:siren) { '123456789' }

  # TODO Refactor for better behaviour description
  # describe wich etablissement the methods siege_social and
  # etablissement_principal return in the various situations
  context 'dossier with siege social & etablissement principal' do
    subject { create :dossier_entreprise_pm_many_reps, siren: siren }

    its('siege_social.type_etablissement') { is_expected.to eq 'SIE' }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'PRI' }
  end

  context 'dossier with SEP' do
    subject { create :dossier_auto_entrepreneur, siren: siren }

    its('siege_social.type_etablissement') { is_expected.to eq 'SEP' }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'SEP' }
  end

  describe 'dossier without siege social' do
    subject { create :dossier_entreprise_without_siege_social, siren: siren }

    its(:siege_social) { is_expected.to be_nil }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'PRI' }
  end

  describe 'dossier without etablissement principal' do
    subject { create :dossier_entreprise_without_etab_principal, siren: siren }

    its('siege_social.type_etablissement') { is_expected.to eq 'SIE' }
    its(:etablissement_principal) { is_expected.to be_nil }
  end

  describe 'dossier TITMC' do
    subject { create :titmc_dossier_entreprise }

    its(:titmc_entreprise) { is_expected.to be_a TribunalInstance::Entreprise }
    its(:titmc_entreprise) { is_expected.to have_attributes forme_juridique: '9999' }
  end

  describe 'origine' do
    it 'is a tribunal commerce' do
      dossier_tc = build :dossier_entreprise, code_greffe: '7608'
      expect(dossier_tc.origine).to eq :tribunal_commerce
    end

    it 'is a tribunal instance' do
      dossier_titmc = build :dossier_entreprise, code_greffe: '6752'
      expect(dossier_titmc.origine).to eq :tribunal_instance
    end
  end
end
