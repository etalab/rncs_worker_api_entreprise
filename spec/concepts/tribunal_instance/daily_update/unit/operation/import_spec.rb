require 'rails_helper'

describe TribunalInstance::DailyUpdate::Unit::Operation::Import, :trb do
  subject { described_class.call path: path, logger: logger }

  let(:logger) { instance_double(Logger).as_null_object }
  let(:path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'xml', filename }

  describe 'success import' do
    let(:filename) { 'flux_RCS.xml' }

    before do
      allow(TribunalInstance::DailyUpdate::Unit::Task::PersistRcs)
        .to receive(:call)
        .and_return(trb_result_success)
    end

    it { is_expected.to be_success }

    it 'logs' do
      expect(logger).to receive(:info).with('Starting import')
      subject
    end

    its([:type])                 { is_expected.to eq 'RCS' }
    its([:dossiers_entreprises]) { are_expected.to all have_attributes code_greffe: '9741' }
    its([:dossiers_entreprises]) { are_expected.to all have_attributes nom_greffe: 'St Denis de la Réunion' }
    its([:dossiers_entreprises]) { are_expected.to all have_attributes titmc_entreprise: be_a(TribunalInstance::Entreprise) }

    it 'calls Task::Persist 3 times' do
      expect(TribunalInstance::DailyUpdate::Unit::Task::PersistRcs)
        .to receive(:call)
        .exactly(3).times
      subject
    end
  end

  describe 'ACT file type' do
    let(:filename) { 'flux_ACT.xml' }

    its([:type]) { is_expected.to eq 'ACT' }

    it { is_expected.to be_success }

    it 'logs that the file is ignored' do
      expect(logger).to receive(:info).with(/Ignoring file \(ACT\) : .+#{filename}/)
      subject
    end

    it 'does not call PersisRcs' do
      expect(TribunalInstance::DailyUpdate::Unit::Task::PersistRcs).not_to receive(:call)
      subject
    end
  end

  describe 'multi greffe file' do
    let(:filename) { 'flux_multi_greffes.xml' }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with('Too many code greffe found 2 (1111, 2222)')
      subject
    end
  end

  describe 'import fails' do
    let(:filename) { 'flux_RCS.xml' }

    before do
      allow(TribunalInstance::DailyUpdate::Unit::Task::PersistRcs)
        .to receive(:call)
        .and_return(trb_result_failure)
    end

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with('An operation failed')
      subject
    end
  end
end
