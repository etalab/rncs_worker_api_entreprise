require 'rails_helper'

describe DataSource::Stock::TribunalInstance::Unit::Operation::MergeGreffeSecondaire do
  subject do
    described_class.call(
      entreprise_secondaire: entreprise_secondaire,
      entreprise_principale: entreprise_principale,
      code_greffe: code_greffe,
      logger: logger
    )
  end

  let(:logger) { instance_double(Logger).as_null_object }
  let(:code_greffe) { '9712' }
  let(:siren) { '123456789' }

  context 'success' do
    let(:entreprise_secondaire) { create :titmc_entreprise, siren: siren, code_greffe: '0000' }
    let(:entreprise_principale) { create :titmc_entreprise_empty, siren: siren, code_greffe: code_greffe }

    it { is_expected.to be_success }

    it 'has établissement from greffe 0000' do
      etab = subject[:entreprise_principale].etablissements.find { |e| e.siret == '12345678900000' }
      expect(etab.adresse).to have_attributes ligne_1: 'Ceci est une adresse d\'établissement'
      expect(etab.adresse).to have_attributes code_greffe: '9712'
    end

    it 'has representants from greffe 0000' do
      rep = subject[:entreprise_principale].representants.find { |r| r.date_creation == '1900-01-01' }
      expect(rep).to have_attributes qualite: '1200'
      expect(rep).to have_attributes code_greffe: '9712'
    end

    it 'has actes from greffe 0000' do
      acte = subject[:entreprise_principale].actes.find { |a| a.numero_depot_manuel == '666' }
      expect(acte).to have_attributes type_acte: 'AA'
      expect(acte).to have_attributes code_greffe: '9712'
    end

    it 'has bilans from greffe 0000' do
      bilan = subject[:entreprise_principale].bilans.find { |b| b.numero == '42' }
      expect(bilan).to have_attributes confidentialite_document_comptable: '1'
      expect(bilan).to have_attributes code_greffe: '9712'
    end

    it 'has observation from greffe 0000' do
      obs = subject[:entreprise_principale].observations.find { |o| o.numero == '1234' }
      expect(obs).to have_attributes code: 'C18'
      expect(obs).to have_attributes code_greffe: '9712'
    end
  end

  context 'when entreprise secondaire has incomplete data' do
    let(:entreprise_secondaire) { create :titmc_entreprise_incomplete, siren: siren, code_greffe: code_greffe }
    let(:entreprise_principale) { create :titmc_entreprise, siren: siren, code_greffe: '0000' }

    it 'do not raise any error' do
      expect(subject.success?).to be_truthy
    end
  end
end
