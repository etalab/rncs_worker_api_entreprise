require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Task::FetchUnits do
  let(:daily_update) { create(:daily_update_tribunal_commerce, files_path: files_path) }
  subject { described_class.call(daily_update: daily_update) }

  # spec/fixtures/tc/flux/2018/04/09
  # ├── 0110
  # ├── 1237
  # └── 9402
  context 'happy path' do
    let(:files_path) { Rails.root.join('spec/fixtures/tc/flux/2018/04/09') }

    it { is_expected.to be_success }

    it 'returns DailyUpdateUnit\'s records' do
      units = subject[:daily_update_units]

      expect(units).to all(be_an_instance_of(DailyUpdateUnit))
    end

    describe 'its daily update units' do
      let(:units) { subject[:daily_update_units] }

      they 'are persisted' do
        expect(units).to all(be_persisted)
      end

      they 'are in "PENDING" status' do
        expect(units).to all(have_attributes(status: 'PENDING'))
      end

      they 'have the correct code greffe' do
        references = units.pluck(:reference)

        expect(references).to contain_exactly('0110', '1237', '9402')
      end

      they 'have the correct files path' do
        units_path = units.pluck(:files_path)

        expect(units_path).to contain_exactly(
          a_string_ending_with('tc/flux/2018/04/09/0110'),
          a_string_ending_with('tc/flux/2018/04/09/1237'),
          a_string_ending_with('tc/flux/2018/04/09/9402'),
        )
      end
    end
  end

  context 'when daily update folder is empty' do
    let(:files_path) { Rails.root.join('spec/fixtures/tc/flux/2018/04/10') }

    it 'fails'
    it 'sets error'
  end

  context 'when units folder name are unexpected' do
    it 'fails'
    it 'sets error'
  end
end
