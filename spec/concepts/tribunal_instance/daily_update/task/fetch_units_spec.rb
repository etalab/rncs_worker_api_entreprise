require 'rails_helper'

describe TribunalInstance::DailyUpdate::Task::FetchUnits do
  subject { described_class.call(daily_update: daily_update, logger: logger) }

  let(:daily_update) { create :daily_update_tribunal_instance, files_path: files_path }
  let(:logger) { instance_double(Logger).as_null_object }

  # spec/fixtures/titmc/flux/2017/05/18
  # ├── 0Hnni3p82a62_20170509212412TITMCFLUX
  # │   ├── 20170509212412TITMCFLUX.md5
  # │   └── 20170509212412TITMCFLUX.zip
  # [...]
  # └── 1eUKHhoF3kQT_20170515205704TITMCFLUX
  #     ├── 20170515205704TITMCFLUX.md5
  #     └── 20170515205704TITMCFLUX.zip
  context 'daily update files are created' do
    let(:files_path) { Rails.root.join('spec/fixtures/titmc/flux/2017/05/18') }

    it { is_expected.to be_success }

    its([:daily_update_units]) { are_expected.to all(be_an_instance_of(DailyUpdateUnit)) }
    its([:daily_update_units]) { are_expected.to all(be_persisted) }
    its([:daily_update_units]) { are_expected.to all(have_attributes(status: 'PENDING')) }

    they 'have all valid references' do
      references = subject[:daily_update_units].pluck(:reference)

      expect(references).to contain_exactly(
        '0O09IEJ9562u',
        '0qLllJmhaRhU',
        '0NKxyI4J7iuk',
        '0Hnni3p82a62',
        '1eUKHhoF3kQT'
      )
    end

    they 'have the correct files path' do
      units_path = subject[:daily_update_units].pluck(:files_path)

      expect(units_path).to contain_exactly(
        a_string_ending_with('titmc/flux/2017/05/18/0O09IEJ9562u_20170504204802TITMCFLUX'),
        a_string_ending_with('titmc/flux/2017/05/18/0qLllJmhaRhU_20170516221805TITMCFLUX'),
        a_string_ending_with('titmc/flux/2017/05/18/0NKxyI4J7iuk_20170517210602TITMCFLUX'),
        a_string_ending_with('titmc/flux/2017/05/18/0Hnni3p82a62_20170509212412TITMCFLUX'),
        a_string_ending_with('titmc/flux/2017/05/18/1eUKHhoF3kQT_20170515205704TITMCFLUX')
      )
    end
  end

  context 'when daily update folder is empty' do
    let(:files_path) { Rails.root.join('spec/fixtures/titmc/flux/2017/05/19') }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with(%r{No directory found in daily update .+2017/05/19})
      subject
    end
  end

  context 'when units folder name are unexpected' do
    let(:files_path) { Rails.root.join('spec/fixtures/titmc/flux/2017/05/20') }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with(%r{Unexpected directory name in daily update .+2017/05/20})
      subject
    end
  end
end
