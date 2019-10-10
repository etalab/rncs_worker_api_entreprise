require 'rails_helper'

describe SectionBODACC do
  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:dummy_pdf_bodacc) do
    Class.new do
      include SectionBODACC
    end
  end

  let(:pdf) { dummy_pdf_bodacc.new }

  it 'returns a valid link' do
    pdf.section_bodacc(siren: '123456789')
    data = [
      'Bulletin Officiel des Annonces Civiles et Commerciales (BODACC)',
      'Lien', 'https://www.bodacc.fr/annonce/liste/123456789'
    ]

    expect(subject).to eq(data)
  end
end
