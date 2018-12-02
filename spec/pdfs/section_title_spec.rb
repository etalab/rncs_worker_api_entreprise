require 'rails_helper'

describe SectionTitle do
  class DummyPdfTitle
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionTitle
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { DummyPdfTitle.new }

  it 'works with good params' do
    pdf.section_title(
      attributes_for(:dossier_entreprise).merge(db_current_date: '2018/01/31')
    )

    data = ['Somewhere in spacetime (code greffe: 1234)',
            'Numéro de gestion: 1968A00666',
            'Extrait d\'immatriculation principale au registre national du commerce et des sociétés',
            'en date du 31 janvier 2018']

    expect(subject).to eq(data)
  end
end
