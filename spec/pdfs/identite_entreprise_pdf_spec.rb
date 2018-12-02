require 'rails_helper'

describe IdentiteEntreprisePdf do
  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { described_class.new template_params }
  let(:siren) { '123456789' }
  let(:template_params) do
    params = { dossier_entreprise_greffe_principal: attributes_for(:dossier_entreprise, siren: siren) }
    nested_data = params[:dossier_entreprise_greffe_principal]
    nested_data[:db_current_date] = '2018-11-25'
    nested_data[:etablissement_principal] = attributes_for(:etablissement_principal, siren: siren)
    nested_data[:representants] = [
      attributes_for(:representant_pm),
      attributes_for(:representant_pp),
      attributes_for(:president_pp)
    ]
    nested_data[:observations] = [
      attributes_for(:observation, date_ajout: '2016-11-30'),
      attributes_for(:observation, date_ajout: nil),
      attributes_for(:observation, date_ajout: '2018-11-25')
    ]

    params
  end
  let(:nested_data) { template_params[:dossier_entreprise_greffe_principal] }

  it 'is a valid Personne Morale PDF' do
    nested_data[:personne_morale] = attributes_for(:personne_morale, siren: siren)

    expected_data = [
      'Somewhere in spacetime (code greffe: 1234)',
      'Numéro de gestion: 1968A00666',
      'Extrait d\'immatriculation principale au registre national du commerce et des sociétés',
      'en date du 25 novembre 2018',
      'Identification de la personne morale',
      'SIREN',                                 '123 456 789',
      'Date d\'immatriculation',               '1968-05-02',
      'Dénomination',                          'Willy Wonka Candies Factory',
      'Forme juridique',                       'Société de bonbons à responsabilité limitée',
      'Capital',                               '1 000.00 Euros',
      'Adresse',                               'Rue des cocotiers 97114 Trois-Rivières',
      'Activités principales',                 'Mangeur de bananes professionnel',
      'Durée de la personne morale',           '99 ans à partir du 1968-05-02',
      'Date de clôture de l\'exercice social', '31 Décembre',
      'Gestion, Direction, Adminisration, Contrôle, Associés ou Membres',
      'Qualité',                   'Contrôleur des comptes',
      'Dénomination',              'Grosse Entreprise de Télécom',
      'SIREN',                     '000 000 000',
      'Forme juridique',           'Société par actions simplifiée',
      'Adresse',                   '3 bis rue des Peupliers Zone Industrielle Sud 34000 Montpellier',
      'Qualité',                   'Directeur Associé',
      'Nom, prénoms',              'DUPONT, Georges Rémi',
      'Date et lieu de naissance', '1907-05-22 Etterbeek',
      'Nationalité',               'Française',
      'Adresse',                   '15 rue de Rivoli 75001 Paris',
      'Qualité',                   'Président',
      'Nom, prénoms',              'DUPONT, Georges Rémi',
      'Date et lieu de naissance', '1907-05-22 Etterbeek',
      'Nationalité',               'Française',
      'Adresse',                   '15 rue de Rivoli 75001 Paris',
      'Renseignements sur l\'établissement principal',
      'Adresse',                'Rue des cocotiers 97114 Trois-Rivières',
      'Date début d\'activité', '1992-07-09',
      'Type d\'exploitation',   'Divers',
      'Observations',
      'page 1/2', # TODO: observation title is on one page and observations are on the next one. how to keep them together ?
      'Mention n°4000A du 2018-11-25',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'Mention n°4000A du 2016-11-30',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'Mention n°4000A du',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'page 2/2'
    ]

    expect(subject).to eq expected_data
    expect(subject).to include 'page 1/2', 'page 2/2'
  end

  it 'is a valid Personne Physique PDF' do
    nested_data[:personne_physique] = attributes_for(:personne_physique, siren: siren)

    expected_data = [
      'Somewhere in spacetime (code greffe: 1234)',
      'Numéro de gestion: 1968A00666',
      'Extrait d\'immatriculation principale au registre national du commerce et des sociétés',
      'en date du 25 novembre 2018',
      'Identification de la personne physique',
      'SIREN',                      '123 456 789',
      'Date d\'immatriculation',    '1968-05-02',
      'Nom, prénoms',               'DUPONT François Philippe',
      'Date et lieu de naissance',  '1970-01-05 Marseille',
      'Nationalité',                'Française',
      'Domicile personnel',         '1 AV FOCH BEL HOTEL 75008 PARIS',
      'Gestion, Direction, Adminisration, Contrôle, Associés ou Membres',
      'Qualité',                    'Contrôleur des comptes',
      'Dénomination',               'Grosse Entreprise de Télécom',
      'SIREN',                      '000 000 000',
      'Forme juridique',            'Société par actions simplifiée',
      'Adresse',                    '3 bis rue des Peupliers Zone Industrielle Sud 34000 Montpellier',
      'Qualité',                    'Directeur Associé',
      'Nom, prénoms',               'DUPONT, Georges Rémi',
      'Date et lieu de naissance',  '1907-05-22 Etterbeek',
      'Nationalité',                'Française',
      'Adresse',                    '15 rue de Rivoli 75001 Paris',
      'Qualité',                    'Président',
      'Nom, prénoms',               'DUPONT, Georges Rémi',
      'Date et lieu de naissance',  '1907-05-22 Etterbeek',
      'Nationalité',                'Française',
      'Adresse',                    '15 rue de Rivoli 75001 Paris',
      'Renseignements sur l\'établissement principal',
      'Adresse',                 'Rue des cocotiers 97114 Trois-Rivières',
      'Date début d\'activité',  '1992-07-09',
      'Type d\'exploitation',    'Divers',
      'Observations',
      'Mention n°4000A du 2018-11-25',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'page 1/2',
      'Mention n°4000A du 2016-11-30',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'Mention n°4000A du',
      'This is a very long observation, so long that you could not imagine it before reading it.',
      'page 2/2'
    ]

    expect(subject).to eq expected_data
  end

  it 'miss section representants & observations' do
    nested_data[:personne_physique] = attributes_for(:personne_physique, siren: siren)
    nested_data[:representants] = []
    nested_data[:observations] = []

    expect(subject).not_to include 'Observations'
    expect(subject).not_to include 'Gestion, Direction, Adminisration, Contrôle, Associés ou Membres'
  end
end
