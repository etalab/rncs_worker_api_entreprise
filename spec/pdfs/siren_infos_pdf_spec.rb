require 'rails_helper'

describe SirenInfosPdf do
  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { described_class.new dossier }

  before { Timecop.freeze(Time.local(2018, 10, 22)) }

  describe 'Auto-entrepreneur' do
    let(:dossier) { create :dossier_auto_entrepreneur }

    # Greffe
    it { is_expected.to include('Greffe AE (code greffe: 1234)') }
    it { is_expected.to include('Numéro de gestion: 1968A00666') }
    # Identité PP
    it { is_expected.to include('SIREN: 123 456 789') }
    it { is_expected.to include('Date d\'immatriculation: 1968-05-02') }
    it { is_expected.to include('Dénomination: DUPONT François Philippe') }
    it { is_expected.to include('Date et lieu de naissance: 1970-01-05 Marseille') }
    it { is_expected.to include('Adresse du siège: 1 AVENUE DES CHAMPS ELYSEES BEL HOTEL') }
    # Représentant
    it { is_expected.to include('Qualité: Président') }
    it { is_expected.to include('Nom prénoms: DUPONT Georges Rémi') }
    it { is_expected.to include('Date et lieu de naissance: 1907-05-22 Etterbeek') }
    it { is_expected.to include('Nationalité: Française') }
    it { is_expected.to include('Adresse: 15 rue de Rivoli 75001 Paris') }
  end

  describe 'Entreprise simple' do
    let(:dossier) { create :dossier_entreprise_simple }

    # Greffe
    it { is_expected.to include('Greffe entreprise simple (code greffe: 1234)') }
    it { is_expected.to include('Numéro de gestion: 1968A00666') }
    # Identité PM
    it { is_expected.to include('SIREN: 111 111 111') }
    it { is_expected.to include('Date d\'immatriculation: 1968-05-02') }
    it { is_expected.to include('Dénomination: Willy Wonka Candies Factory') }
    it { is_expected.to include('Forme juridique: Société de bonbons à responsabilité limitée') }
    it { is_expected.to include('Capital: 1000.0 Euros') }
    it { is_expected.to include('Adresse: Rue des cocotiers 97114 Trois-Rivières') }
    it { is_expected.to include('Durée: 22/10/2117') }
    it { is_expected.to include('Date de clôture: 31 Décembre') }
    # Représentant
    it { is_expected.to include('Qualité: Président') }
    it { is_expected.to include('Dénomination: Grosse Entreprise de Télécom') }
    it { is_expected.to include('SIREN: 333 444 555') }
    it { is_expected.to include('Forme juridique: Société par actions simplifiée') }
    it { is_expected.to include('Adresse:  rue des Peupliers Zone Industrielle Sud 34000 Montpellier') }
  end

  describe 'Dossier entreprise PM with many representants' do
    let(:dossier) { create :dossier_entreprise_pm_many_reps }

    # Greffe
    it { is_expected.to include('Greffe entreprise complexe (code greffe: 1234)') }
    it { is_expected.to include('Numéro de gestion: 1968A00666') }
    # Identité PM
    it { is_expected.to include('SIREN: 222 222 222') }
    it { is_expected.to include('Date d\'immatriculation: 1968-05-02') }
    it { is_expected.to include('Dénomination: Willy Wonka Candies Factory') }
    it { is_expected.to include('Forme juridique: Société de bonbons à responsabilité limitée') }
    it { is_expected.to include('Capital: 1000.0 Euros') }
    it { is_expected.to include('Adresse: Rue des cocotiers 97114 Trois-Rivières') }
    it { is_expected.to include('Durée: 22/10/2117') }
    it { is_expected.to include('Date de clôture: 31 Décembre') }
    # Représentant*S*
    ## Président
    it { is_expected.to include('Qualité: Président') }
    it { is_expected.to include('Dénomination: Grosse Entreprise de Télécom') }
    it { is_expected.to include('SIREN: 333 444 555') }
    it { is_expected.to include('Forme juridique: Société par actions simplifiée') }
    it { is_expected.to include('Adresse:  rue des Peupliers Zone Industrielle Sud 34000 Montpellier') }
    ## Autres
    it 'has more représentants' do
      nb_rep = dossier.representants.size
      _, reps = subject.split('Représentants')

      expect(reps.size).to eq(nb_rep*5)
    end
  end

  describe 'all fields are nil but PDF generated' do
    let(:dossier) { DossierEntreprise.new.tap(&:save) }

    before { Etablissement.new(dossier_entreprise: dossier).tap(&:save) }

    context 'with PP' do
      before { PersonnePhysique.new(dossier_entreprise: dossier).tap(&:save) }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 11 }
    end

    context 'with PM' do
      before { PersonneMorale.new(dossier_entreprise: dossier).tap(&:save) }

      # check PDF size instead of checking ALL nil values
      its(:size) { is_expected.to eq 14 }
    end
  end
end
