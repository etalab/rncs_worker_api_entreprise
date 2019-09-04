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
  it_behaves_like '.import'

  let(:siren) { '123456789' }

  describe '.immatriculation_principale' do
    let(:siren) { '123456789' }

    subject { described_class.immatriculation_principale(siren) }

    context 'with a single or zero immatriculation principale found in db' do
      it 'returns nil if none are found' do
        create(:dossier_entreprise, siren: siren, type_inscription: 'S')

        expect(subject).to be_nil
      end

      it 'returns the only existing one if any' do
        immat_pri = create(:dossier_entreprise, siren: siren, type_inscription: 'P')

        expect(subject).to eq(immat_pri)
      end
    end

    context 'with multiple immatriculations principales found in db' do
      let!(:old_immat) { create(:dossier_entreprise, siren: siren, type_inscription: 'P', date_immatriculation: '2018-01-01') }
      let!(:latest_immat) { create(:dossier_entreprise, siren: siren, type_inscription: 'P', date_immatriculation: '2019-01-01') }

      it 'returns the latest' do
        expect(subject).to eq(latest_immat)
      end

      it 'returns nil if :date_immatriculation is not filled for at least one' do
        old_immat.update(date_immatriculation: nil)

        expect(subject).to be_nil
      end
    end
  end

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

  describe 'type_greffe' do
    it 'recognizes a tribunal commerce code' do
      dossier_tc = build :dossier_entreprise, code_greffe: '7608'
      expect(dossier_tc.type_greffe).to eq :tribunal_commerce
    end

    it 'recognizes a tribunal instance code' do
      dossier_titmc = build :dossier_entreprise, code_greffe: '6752'
      expect(dossier_titmc.type_greffe).to eq :tribunal_instance
    end
  end
end
