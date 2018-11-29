require 'rails_helper'

describe SectionIdentitePM do
  class DummyPdfPM
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionIdentitePM
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { DummyPdfPM.new }
  let(:siren) { '123456789' }
  let(:params) do
    {
      personne_morale: attributes_for(:personne_morale, siren: siren),
      etablissement_principal: attributes_for(:etablissement_address_complete, siren: siren),
      date_immatriculation: '2015-05-19'
    }
  end

  it 'works with complete address' do
    pdf.section_identite_pm params

    data = ['Identification de la personne morale',
            'SIREN',                                 '123 456 789',
            'Date d\'immatriculation',               '2015-05-19',
            'Dénomination',                          'Willy Wonka Candies Factory',
            'Forme juridique',                       'Société de bonbons à responsabilité limitée',
            'Capital',                               '1 000.00 Euros',
            'Adresse',                               'C\'est ici Rue des cocotiers (Rhumerie) 97114 Trois-Rivières',
            'Activités principales',                 'Mangeur de bananes professionnel',
            'Durée de la personne morale',           '99 ans à partir du 2015-05-19',
            'Date de clôture de l\'exercice social', '31 Décembre']

    expect(subject).to eq data
  end

  it 'works with incomplete address' do
    pdf.section_identite_pm(
      personne_morale: attributes_for(:personne_morale, siren: siren),
      etablissement_principal: attributes_for(:etablissement_principal),
      date_immatriculation: '2015-05-18'
    )

    expect(subject).to include 'Rue des cocotiers 97114 Trois-Rivières'
  end

  it 'works with foreign address' do
    params[:etablissement_principal] = attributes_for(:etablissement_etranger)
    pdf.section_identite_pm params

    expect(subject).to include 'Rue des cocotiers 97114 Trois-Rivières (Syldavie)'
  end

  it 'works with nil capital' do
    params[:personne_morale][:capital] = nil
    pdf.section_identite_pm params

    expected_capital_index = subject.index('Capital') + 1
    label_after_capital = subject[expected_capital_index]
    expect(label_after_capital).to eq 'Adresse' # and not "nil €"
  end

  it 'works with capital but missing devise' do
    params[:personne_morale][:devise] = nil
    pdf.section_identite_pm params

    expect(subject).to include '1 000.00'
  end

  it 'works with nil date_immatriculation' do
    params[:date_immatriculation] = nil
    pdf.section_identite_pm params

    expect(subject).to include '99 ans à partir du'
  end

  it 'works with nil duree_pm' do
    params[:personne_morale][:duree_pm] = nil
    pdf.section_identite_pm params

    expect(subject).to include 'ans à partir du 2015-05-19'
  end
end
