require 'rails_helper'

describe TribunalInstance::DailyUpdate::Unit::Operation::Load, :trb do
  subject { described_class.call daily_update_unit: unit, logger: logger }

  let(:unit) { create :daily_update_unit, files_path: path }
  let(:logger) { instance_double(Logger).as_null_object }

  describe 'Daily update unit with 2 transmissions' do
    let(:path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'flux', '2017', '05', '18', '0Hnni3p82a62_20170509212412TITMCFLUX' }

    before do
      allow(TribunalInstance::DailyUpdate::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_success)
    end

    it { is_expected.to be_success }
    its([:transmissions]) { is_expected.to have_attributes count: 2 }

    it 'logs import starts' do
      expect(logger).to receive(:info).with(/Starting import of .+0Hnni3p82a62_20170509212412TITMCFLUX/)
      subject
    end

    it 'logs how many transmissions are found' do
      expect(logger).to receive(:info).with('2 files founds')
      subject
    end

    it 'calls LoadTransmission' do
      ['20170509212412TITMCFLUX.zip', '20170509212415TITMCFLUX.zip'].each do |filename|
        expect(TribunalInstance::DailyUpdate::Unit::Operation::LoadTransmission)
          .to receive(:call)
          .with(path: a_string_ending_with(filename), logger: logger)
      end

      subject
    end

    it 'logs success' do
      expect(logger).to receive(:info).with('All transmissions imported successfully')
      subject
    end
  end

  context 'when one transmission fails' do
    let(:path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'flux', '2017', '05', '18', '0Hnni3p82a62_20170509212412TITMCFLUX' }

    before do
      allow(TribunalInstance::DailyUpdate::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .and_return(trb_result_failure)
    end

    it { is_expected.to be_failure }
    its([:transmissions]) { is_expected.to have_attributes count: 2 }

    it 'only calls LoadTransmission once' do
      expect(TribunalInstance::DailyUpdate::Unit::Operation::LoadTransmission)
        .to receive(:call)
        .once

      subject
    end
  end

  context 'when no transmission found' do
    let(:path) { Rails.root.join 'spec', 'fixtures', 'titmc', 'flux', '2017', '05', '18', '0NKxyI4J7iuk_20170517210602TITMCFLUX' }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with(/No transmission found in .+0NKxyI4J7iuk_20170517210602TITMCFLUX/)
      subject
    end
  end
end
