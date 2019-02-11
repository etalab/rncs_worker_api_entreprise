require 'rails_helper'

describe DataSource::Stock::TribunalInstance::Unit::Operation::Import, :trb do
  subject { described_class.call path: unit_path, code_greffe: '9712', logger: logger }

  let(:unit_path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'xml', '9712_S1_20180505_lot02.xml' }
  let(:logger) { object_double(Rails.logger, info: true).as_null_object }

  context 'success' do
    it { is_expected.to be_success }

    it 'logs' do
      expect(logger).to receive(:info).with('Starting import')
      subject
    end

    its([:dossiers_entreprises]) { are_expected.to all be_persisted }
    its([:dossiers_entreprises]) { are_expected.to all have_attributes code_greffe: '9712' }
    its([:dossiers_entreprises]) { are_expected.to all have_attributes titmc_entreprise: be_a(TribunalInstance::Entreprise) }

    it 'persists 2 entreprises' do
      expect { subject }.to change(TribunalInstance::Entreprise, :count).by 2
    end

    it 'persists some adresses' do
      expect { subject }.to change(TribunalInstance::Adresse, :count).by 10
    end

    it 'persists some data from greffe secondaire' do
      expect { subject }.to change(TribunalInstance::Observation, :count).by 3
    end

    it 'calls find and merge operation twice' do
      expect(DataSource::Stock::TribunalInstance::Unit::Operation::MergeGreffeSecondaire)
        .to receive(:call)
        .and_return(trb_result_success)
        .twice

      subject
    end
  end

  describe 'when merge greffe secondaire fails' do
    before do
      allow(DataSource::Stock::TribunalInstance::Unit::Operation::MergeGreffeSecondaire)
        .to receive(:call)
        .and_return(trb_result_failure)
    end

    it { is_expected.to be_failure }
  end

  context 'when entreprise in greffe secondaire not in greffe principal' do
    let(:unit_path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'xml', 'missing_entreprise_principale.xml' }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with('No entreprise found in greffe principal for entreprise 123456789 of greffe secondaire')
      subject
    end
  end
end
