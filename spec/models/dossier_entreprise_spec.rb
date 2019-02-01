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

  # Associations
  it { is_expected.to have_one(:personne_morale) }
  it { is_expected.to have_one(:personne_physique) }
  it { is_expected.to have_many(:representants) }
  it { is_expected.to have_many(:observations) }
  it { is_expected.to have_many(:etablissements) }

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

  describe '#destroy' do
    let(:dossier) { create(:dossier_entreprise_simple) }
    before { dossier }

    subject { dossier.destroy }

    it 'does not affect other dossiers saved' do
      dossier_to_keep = create(:dossier_entreprise_simple)

      expect{ subject }.to change(DossierEntreprise, :count).by(-1)
      expect(dossier_to_keep).to be_persisted
    end

    it 'also delete associated personne morale' do
      expect{ subject }.to change(PersonneMorale, :count).by(-1)
    end

    it 'also delete associated personne physique' do
      dossier_entrepreneur = create(:dossier_auto_entrepreneur)

      expect{ dossier_entrepreneur.destroy }.to change(PersonnePhysique, :count).by(-1)
    end

    it 'also delete associated etablissements' do
      expect{ subject }.to change(Etablissement, :count).by(-1)
    end

    it 'also delete associated representants' do
      expect{ subject }.to change(Representant, :count).by(-3)
    end

    it 'also delete associated observations' do
      expect{ subject }.to change(Observation, :count).by(-3)
    end
  end
end
