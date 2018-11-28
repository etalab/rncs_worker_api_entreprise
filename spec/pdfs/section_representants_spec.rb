require 'rails_helper'

describe SectionRepresentants do
  class DummyPdfRep
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionRepresentants
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { DummyPdfRep.new }

  it 'works' do
    params = {
      representants: [
        attributes_for(:president_pp, nom_patronyme: nil),
        attributes_for(:representant_pm_with_complete_address),
        attributes_for(:representant_pp_with_incomplete_address)
      ]
    }

    pdf.section_representants params

    data = [
      'Gestion, Direction, Adminisration, Contrôle, Associés ou Membres',
      'Qualité',                   'Président',
      'Nom, prénoms',              ', Georges Rémi',
      'Date et lieu de naissance', '1907-05-22 Etterbeek',
      'Nationalité',               'Française',
      'Adresse',                   '15 rue de Rivoli 75001 Paris',

      'Qualité',                   'Contrôleur des comptes',
      'Dénomination',              'Grosse Entreprise de Télécom',
      'SIREN',                     '000 000 000',
      'Forme juridique',           'Société par actions simplifiée',
      'Adresse',                   '3 bis rue des Peupliers Zone Industrielle Sud 34000 Montpellier',

      'Qualité',                   'Directeur Associé',
      'Nom, prénoms',              'DUPONT, Georges Rémi',
      'Date et lieu de naissance', '1907-05-22 Etterbeek',
      'Nationalité',               'Française',
      'Adresse',                   '15 rue de Rivoli 75001 Paris'
    ]

    expect(subject).to eq data
  end

  context 'type_representant' do
    it 'matches anything like pHysiQue' do
      pdf.section_representants representants: [attributes_for(:representant_pp, type_representant: 'Truc pHysiquE.?')]

      expect(subject).to include 'Nom, prénoms'
    end

    it 'matches anything like mOralE' do
      pdf.section_representants representants: [attributes_for(:representant_pm, type_representant: '88 mOralEs!')]

      expect(subject).to include 'Dénomination'
    end

    it 'logs an error' do
      expect(Raven).to receive(:capture_message).with 'Unhandled type_representant (rentier)'
      pdf.section_representants representants: [attributes_for(:representant, type_representant: 'rentier')]
    end
  end
end
