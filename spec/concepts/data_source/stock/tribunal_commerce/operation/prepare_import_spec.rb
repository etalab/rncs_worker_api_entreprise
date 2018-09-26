require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Operation::PrepareImport do
  let(:stock_param) { create(:stock_tribunal_commerce, files_path: path_param) }
  subject { described_class.call(stock: stock_param) }

  context 'when no zip files are found in stock path' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'tc', 'no_stocks_here') }

    it { is_expected.to be_failure }
    its([:error]) { is_expected.to eq("No stock units found in #{path_param}.") }
    its([:stock_units]) { is_expected.to be_nil }
  end

  context 'when file names do not match specified pattern' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'tc', 'falsey_stocks') }

    it { is_expected.to be_failure }
    its([:error]) { is_expected.to eq("Unexpected filenames in #{path_param}.") }
    its([:stock_units]) { is_expected.to be_nil }
  end

  # 3 greffe's stock example inside this repo :
  # spec/fixtures/tc/stock/2016/09/28
  # ├── 1234_S1_20160928.zip
  # ├── 3141_S1_20160928.zip
  # └── 0666_S1_20160928.zip
  context 'when stock units are found' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'tc', 'stock', '2016', '09', '28') }

    it 'saves each greffe\'s stock unit in db' do
      expect { subject }.to change(StockUnit, :count).by(3)
    end

    it 'returns the stock units list' do
      subject
      created_units = StockUnit.all

      expect(subject[:stock_units]).to eq(created_units)
    end

    describe 'associated stock units' do
      it 'has valid code_greffe' do
        subject
        created_unit = StockUnit.where(code_greffe: '1234')
          .or(StockUnit.where(code_greffe: '3141'))
          .or(StockUnit.where(code_greffe: '0666'))

        expect(created_unit.size).to eq(3)
      end

      it 'knows its own path' do
        subject
        unit = StockUnit.where(code_greffe: '1234').first

        expect(unit.file_path).to end_with('spec/fixtures/tc/stock/2016/09/28/1234_S1_20160928.zip')
      end

      it 'has a "pending" status' do
        subject
        units_status = StockUnit.pluck(:status)

        expect(units_status).to all(eq('PENDING'))
      end
    end
  end
end
