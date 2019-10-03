require 'rails_helper'

describe TribunalInstance::Stock::Unit::Operation::ResetDatabase, :trb do
  subject { described_class.call code_greffe: code_greffe, logger: logger }

  let(:code_greffe) { '9712' }
  let(:logger) { object_double(Rails.logger, info: true).as_null_object }

  before do
    create :titmc_dossier_entreprise, code_greffe: '1111'
    create :titmc_dossier_entreprise, code_greffe: code_greffe
  end

  it 'deletes dossier' do
    expect { subject }.to change(DossierEntreprise, :count).by(-1)
  end

  it 'deletes adresses' do
    expect { subject }.to change(TribunalInstance::Adresse, :count).by(-9)
  end

  it 'deletes entreprise' do
    expect { subject }.to change(TribunalInstance::Entreprise, :count).by(-1)
  end

  it 'deletes établissements' do
    expect { subject }.to change(TribunalInstance::Etablissement, :count).by(-2)
  end

  it 'deletes observations' do
    expect { subject }.to change(TribunalInstance::Observation, :count).by(-4)
  end

  it 'deletes représentants' do
    expect { subject }.to change(TribunalInstance::Representant, :count).by(-2)
  end

  it 'remains others greffes' do
    subject
    expect(DossierEntreprise.all).to contain_exactly(
      an_object_having_attributes(code_greffe: '1111')
    )
  end
end
