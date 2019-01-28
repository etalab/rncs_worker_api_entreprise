require 'rails_helper'

describe DataSource::Stock::TribunalInstance::Unit::Operation::ResetDatabase, :trb do
  subject { described_class.call code_greffe: code_greffe }

  let(:code_greffe) { '9712' }

  before do
    create_list :dossier_entreprise_simple, 2, code_greffe: '1111'
    create_list :titmc_dossier_entreprise, 3, code_greffe: code_greffe
  end

  it 'deletes 3 dossiers' do
    expect { subject }.to change(DossierEntreprise, :count).by -3
  end

  it 'deletes one TITMC entreprise' do
    expect { subject }.to change(TribunalInstance::Entreprise, :count).by -3
  end

  it 'deletes all adresses établissement' do
    expect { subject }.to change(TribunalInstance::AdresseEtablissement, :count).by -6
  end

  it 'remains other greffe' do
    subject
    expect(DossierEntreprise.all).to contain_exactly(
      an_object_having_attributes(code_greffe: '1111'),
      an_object_having_attributes(code_greffe: '1111')
    )
  end
end
