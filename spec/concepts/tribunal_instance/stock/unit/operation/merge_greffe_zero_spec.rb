require 'rails_helper'

describe TribunalInstance::Stock::Unit::Operation::MergeGreffeZero do
  subject do
    described_class.call(
      entreprise_code_greffe_0000: entreprise_code_greffe_0000,
      entreprise_related: entreprise_related,
      code_greffe: code_greffe,
      logger: logger
    )
  end

  let(:logger) { instance_double(Logger).as_null_object }
  let(:code_greffe) { '9712' }
  let(:siren) { '123456789' }

  context 'success' do
    let(:entreprise_code_greffe_0000) { create :titmc_entreprise,       siren: siren, code_greffe: '0000' }
    let(:entreprise_related)          { create :titmc_entreprise_empty, siren: siren, code_greffe: code_greffe }

    it { is_expected.to be_success }

    it 'has établissement from greffe 0000' do
      etab = subject[:entreprise_related].etablissements.find { |e| e.siret == '12345678900000' }
      expect(etab.adresse).to have_attributes(ligne_1: 'Ceci est une adresse d\'établissement')
      expect(etab.adresse).to have_attributes(code_greffe: '9712')
    end

    it 'has representants from greffe 0000' do
      rep = subject[:entreprise_related].representants.find { |r| r.date_creation == '1900-01-01' }
      expect(rep).to have_attributes(qualite: '1200')
      expect(rep).to have_attributes(code_greffe: '9712')
    end

    it 'has observation from greffe 0000' do
      obs = subject[:entreprise_related].observations.find { |o| o.numero == '1234' }
      expect(obs).to have_attributes(code: 'C18')
      expect(obs).to have_attributes(code_greffe: '9712')
    end
  end

  context 'when entreprise in code greffe 0000 has incomplete data' do
    let(:entreprise_code_greffe_0000) { create :titmc_entreprise_incomplete, siren: siren, code_greffe: code_greffe }
    let(:entreprise_related)          { create :titmc_entreprise,            siren: siren, code_greffe: '0000' }

    it 'do not raise any error' do
      expect(subject.success?).to be_truthy
    end
  end
end
