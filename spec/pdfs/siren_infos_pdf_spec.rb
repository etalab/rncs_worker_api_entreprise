require 'rails_helper'

describe SirenInfosPdf do
  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { described_class.new dossier }

  before { Timecop.freeze(Time.local(2018, 10, 22)) }

  describe 'Auto-entrepreneur' do
    let(:dossier) { create :dossier_auto_entrepreneur }

    let(:expected_data) do
      [
        'Greffe AE (code greffe: 1234)',
        'Numéro de gestion: 1968A00666',
        'Informations d\'identité d\'entreprise',
        'En date du 22 octobre 2018',
        'Identité de l\'entreprise',
        'SIREN: 123 456 789',
        'Date d\'immatriculation: 1968-05-02',
        'Dénomination: DUPONT François Philippe',
        'Date et lieu de naissance: 1970-01-05 Marseille',
        'Adresse du siège: 1 AVENUE DES CHAMPS ELYSEES BEL HOTEL',
        'Représentants',
        'Qualité: Président',
        'Nom prénoms: DUPONT Georges Rémi',
        'Date et lieu de naissance: 1907-05-22 Etterbeek',
        'Nationalité: Française',
        'Adresse: 15 rue de Rivoli 75001 Paris',
        'Renseignements sur l\'établissement principal',
        'Adresse: Rue des cocotiers 97114 Trois-Rivières',
        'Date début d\'activité: 1992-07-09',
        'Type d\'exploitation: Divers'
      ]
    end

    it { is_expected.to include(*expected_data) }
    its(:size) { is_expected.to eq expected_data.size }
  end

  describe 'Entreprise simple' do
    let(:dossier) { create :dossier_entreprise_simple }

    let(:expected_data) do
      [
        'Greffe entreprise simple (code greffe: 1234)',
        'Numéro de gestion: 1968A00666',
        'Informations d\'identité d\'entreprise',
        'En date du 22 octobre 2018',
        'Identité de l\'entreprise',
        'SIREN: 111 111 111',
        'Date d\'immatriculation: 1968-05-02',
        'Dénomination: Willy Wonka Candies Factory',
        'Forme juridique: Société de bonbons à responsabilité limitée',
        'Capital: 1000.0 Euros',
        'Adresse: Rue des cocotiers 97114 Trois-Rivières',
        'Durée: 22/10/2117',
        'Date de clôture: 31 Décembre',
        'Représentants',
        'Qualité: Président',
        'Dénomination: Grosse Entreprise de Télécom',
        'SIREN: 333 444 555',
        'Forme juridique: Société par actions simplifiée',
        'Adresse:  rue des Peupliers Zone Industrielle Sud 34000 Montpellier',
        'Renseignements sur l\'établissement principal',
        'Adresse: Rue des cocotiers 97114 Trois-Rivières',
        'Date début d\'activité: 1992-07-09',
        'Type d\'exploitation: Divers',
        'Observations',
        'Mention n°4000A du 12/12/12',
        'I can see you'
      ]
    end

    it { is_expected.to include(*expected_data) }
    its(:size) { is_expected.to eq expected_data.size }
  end

  describe 'Dossier entreprise PM with many representants' do
    let(:dossier) { create :dossier_entreprise_pm_many_reps }

    let(:expected_data_begining) do
      [
        'Greffe entreprise complexe (code greffe: 1234)',
        'Numéro de gestion: 1968A00666',
        'Informations d\'identité d\'entreprise',
        'En date du 22 octobre 2018',
        'Identité de l\'entreprise',
        'SIREN: 222 222 222',
        'Date d\'immatriculation: 1968-05-02',
        'Dénomination: Willy Wonka Candies Factory',
        'Forme juridique: Société de bonbons à responsabilité limitée',
        'Capital: 1000.0 Euros',
        'Adresse: Rue des cocotiers 97114 Trois-Rivières',
        'Durée: 22/10/2117',
        'Date de clôture: 31 Décembre',
        'Représentants',
        'Qualité: Président',
        'Dénomination: Grosse Entreprise de Télécom',
        'SIREN: 333 444 555',
        'Forme juridique: Société par actions simplifiée',
        'Adresse:  rue des Peupliers Zone Industrielle Sud 34000 Montpellier',
      ]
    end

    let(:expected_data_end) do
      [
        'Renseignements sur l\'établissement principal',
        'Adresse: Rue des cocotiers 97114 Trois-Rivières',
        'Date début d\'activité: 1992-07-09',
        'Type d\'exploitation: Divers'
      ]
    end

    it { is_expected.to start_with(*expected_data_begining) }
    it { is_expected.to end_with(*expected_data_end) }
    its(:size) { is_expected.to be >  (expected_data_begining.size + expected_data_end.size) }
  end

  describe 'with many observations' do
    before { create_list :observation, 2, dossier_entreprise: dossier }

    let(:dossier) { create :dossier_entreprise_simple }
    let(:observations) do
      [
        'Observations',
        'Mention n°4000A du 12/12/12',
        'I can see you',
        'Mention n°4000A du 12/12/12',
        'I can see you'
      ]
    end

    it { is_expected.to include(*observations) }
  end

  describe 'all fields are nil but PDF generated' do
    let(:dossier) { DossierEntreprise.new.tap(&:save) }

    before { Etablissement.new(dossier_entreprise: dossier).tap(&:save) }

    context 'with PP' do
      before { PersonnePhysique.new(dossier_entreprise: dossier).tap(&:save) }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 15 }
    end

    context 'with PM' do
      before { PersonneMorale.new(dossier_entreprise: dossier).tap(&:save) }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 18 }
    end

    describe 'entreprise without etablissement principal' do
      before { create :siege_social, dossier_entreprise: dossier }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 15 }
    end

    describe 'entreprise without siege social' do
      before { create :etablissement_principal, dossier_entreprise: dossier }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 15 }
    end
  end

  describe 'production issue' do
    let(:dossier) { DossierEntreprise.new.tap(&:save) }

    before do
      create :representant, dossier_entreprise: dossier, type_representant: 'P. Physique', nom_patronyme: 'buggy', prenoms: 'spacing'
    end

    it { is_expected.to include('Nom prénoms: BUGGY spacing') }
  end

  context 'wrong expected values' do
    subject(:pdf) { described_class.new dossier }
    let(:dossier) { DossierEntreprise.new.tap(&:save) }

    before do
      create :representant, dossier_entreprise: dossier, type_representant: 'P. Banale'
    end

    it 'raises an error' do
      expect(Rails.logger).to receive(:error).with('Unhandled type_representant')
      pdf.render
    end
  end
end
