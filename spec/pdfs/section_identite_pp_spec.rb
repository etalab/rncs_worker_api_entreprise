require 'rails_helper'

describe SectionIdentitePP do
  class DummyPdfPP
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionIdentitePP
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { DummyPdfPP.new }
  let(:siren) { '123456789' }
  let(:params) do
    {
      personne_physique: attributes_for(:personne_physique_adresse_complete, siren: siren),
      date_immatriculation: '2015-05-19'
    }
  end

  it 'works with valid params' do
    pdf.section_identite_pp params

    data = ['Identification de la personne physique',
            'SIREN',                     '123 456 789',
            'Date d\'immatriculation',   '2015-05-19',
            'Nom, prénoms',              'DUPONT François Philippe',
            'Date et lieu de naissance', '1970-01-05 Marseille',
            'Nationalité',               'Française',
            'Domicile personnel',        'Chez Bébert 1 AV FOCH BEL HOTEL 75008 PARIS']

    expect(subject).to eq data
  end

  it 'works with incomplete addresse' do
    incomplete_params = {
      personne_physique: attributes_for(:personne_physique, siren: siren),
      date_immatriculation: '2015-05-09'
    }
    pdf.section_identite_pp incomplete_params

    expect(subject).to include '1 AV FOCH BEL HOTEL 75008 PARIS'
  end

  it 'works with foreign address' do
    params = {
      personne_physique: attributes_for(:personne_physique_etrangere, siren: siren),
      date_immatriculation: '1939-08-10'
    }
    pdf.section_identite_pp params

    expect(subject).to include '1 AV FOCH BEL HOTEL 75008 PARIS (Bordurie)'
  end

  it 'works with nil nom' do
    params[:personne_physique][:nom_patronyme] = nil
    pdf.section_identite_pp params

    expect(subject).to include 'François Philippe'
  end
end
