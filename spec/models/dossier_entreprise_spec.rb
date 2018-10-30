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

  describe 'siren with siege social & etablissement principal' do
    subject { create :dossier_entreprise_pm_many_reps, siren: siren }

    its(:siege_social) { is_expected.to be_an(Etablissement) }
    its('siege_social.siren') { is_expected.to eq siren }
    its('siege_social.type_etablissement') { is_expected.to eq 'SIE' }

    its(:etablissement_principal) { is_expected.to be_an(Etablissement) }
    its('etablissement_principal.siren') { is_expected.to eq siren }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'PRI' }
  end

  describe 'siren with SEP' do
    subject { create :dossier_auto_entrepreneur, siren: siren }

    its(:siege_social) { is_expected.to be_an(Etablissement) }
    its('siege_social.siren') { is_expected.to eq siren }
    its('siege_social.type_etablissement') { is_expected.to eq 'SEP' }

    its(:etablissement_principal) { is_expected.to be_an(Etablissement) }
    its('etablissement_principal.siren') { is_expected.to eq siren }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'SEP' }
  end

  describe 'siren without siege social' do
    subject { create :dossier_entreprise_without_siege_social, siren: siren }

    its(:siege_social) { is_expected.to be_nil }

    its(:etablissement_principal) { is_expected.to be_an(Etablissement) }
    its('etablissement_principal.siren') { is_expected.to eq siren }
    its('etablissement_principal.type_etablissement') { is_expected.to eq 'PRI' }
  end

  describe 'siren without etablissement principal' do
    subject { create :dossier_entreprise_without_etab_principal, siren: siren }

    its(:siege_social) { is_expected.to be_an(Etablissement) }
    its('siege_social.siren') { is_expected.to eq siren }
    its('siege_social.type_etablissement') { is_expected.to eq 'SIE' }

    its(:etablissement_principal) { is_expected.to be_nil }
  end
end
