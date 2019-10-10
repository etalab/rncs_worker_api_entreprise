require 'rails_helper'

describe SectionEtablissementPrincipal do
  class DummyPdfEtab
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionEtablissementPrincipal
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }

  let(:pdf) { DummyPdfEtab.new }

  it 'works with address complete' do
    params = { etablissement_principal: attributes_for(:etablissement_address_complete) }
    pdf.section_etablissement_principal(params)

    data = [
      'Renseignements sur l\'établissement principal',
      'Adresse', 'C\'est ici Rue des cocotiers (Rhumerie) 97114 Trois-Rivières',
      'Date début d\'activité', '1992-07-09',
      'Type d\'exploitation', 'Divers'
    ]

    expect(subject).to eq(data)
  end

  it 'works with address incomplete' do
    params = { etablissement_principal: attributes_for(:etablissement_address_incomplete) }
    pdf.section_etablissement_principal(params)

    expect(subject).to include('Rue des cocotiers 97114 Trois-Rivières')
  end

  it 'works with foreign address' do
    params = { etablissement_principal: attributes_for(:etablissement_etranger) }
    pdf.section_etablissement_principal(params)

    expect(subject).to include('Rue des cocotiers 97114 Trois-Rivières (Syldavie)')
  end
end
