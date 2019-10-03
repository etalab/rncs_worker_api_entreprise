require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Task::FetchPartialStocks do
  let(:daily_update) { create(:daily_update_tribunal_commerce, partial_stock: true, files_path: files_path) }
  subject { described_class.call(daily_update: daily_update) }

  # spec/fixtures/tc/partial_stock/2018/04/09
  # ├── 1234_S2_20180409.zip
  # ├── 5556_S2_20180409.zip
  # └── 0384_S2_20180409.zip
  context 'happy path' do
    let(:files_path) { Rails.root.join('spec/fixtures/tc/partial_stock/2018/04/09') }

    it { is_expected.to be_success }

    it 'returns DailyUpdateUnit\'s records' do
      units = subject[:partial_stock_units]

      expect(units).to all(be_an_instance_of(DailyUpdateUnit))
    end

    describe 'its daily update units' do
      let(:units) { subject[:partial_stock_units] }

      they 'are persisted' do
        expect(units).to all(be_persisted)
      end

      they 'are in "PENDING" status' do
        expect(units).to all(have_attributes(status: 'PENDING'))
      end

      they 'have the correct code greffe' do
        references = units.pluck(:reference)

        expect(references).to contain_exactly('1234', '5556', '0384')
      end

      they 'have the correct files path' do
        units_path = units.pluck(:files_path)

        expect(units_path).to contain_exactly(
          a_string_ending_with('tc/partial_stock/2018/04/09/1234_S2_20180409.zip'),
          a_string_ending_with('tc/partial_stock/2018/04/09/5556_S2_20180409.zip'),
          a_string_ending_with('tc/partial_stock/2018/04/09/0384_S2_20180409.zip')
        )
      end
    end
  end

  context 'when daily update folder is empty' do
    it 'fails'
    it 'sets error'
  end

  context 'when units folder name are unexpected' do
    it 'fails'
    it 'sets error'
  end
end
