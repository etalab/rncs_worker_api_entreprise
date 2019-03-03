require 'rails_helper'

describe TribunalInstance::Stock::Operation::PrepareImport do
  subject { described_class.call(stock: stock) }

  let(:stock) { create(:stock_titmc, files_path: path_param) }

  context 'when no zip files are found in stock path' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'titmc', 'no_stocks_here') }

    it { is_expected.to be_failure }
    its([:error]) { is_expected.to eq("No stock units found in #{path_param}.") }
    its([:stock_units]) { is_expected.to be_nil }

    it 'does not persist any stock unit' do
      expect { subject }.not_to change(StockUnit, :count)
    end
  end

  context 'when file names do not match specified pattern' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'titmc', 'falsey_stocks') }

    it { is_expected.to be_failure }
    its([:error]) { is_expected.to eq("Unexpected filenames in #{path_param}.") }
    its([:stock_units]) { is_expected.to be_nil }

    it 'does not persist any stock unit' do
      expect { subject }.not_to change(StockUnit, :count)
    end
  end

  # 3 greffe's stock example inside this repo :
  # spec/fixtures/titmc/stock/2018/05/05
  # ├── 9721_S1_20180505_lot01.zip
  # ├── 9721_S1_20180505_lot02.zip
  # └── 9761_S1_20180505_lot01.zip
  context 'when stock units are found' do
    let(:path_param) { Rails.root.join('spec', 'fixtures', 'titmc', 'stock', '2018', '05', '05') }

    it 'saves greffe\'s stock unit in db' do
      expect { subject }.to change(StockUnit, :count).by(2)
    end

    its([:stock_units]) { are_expected.to eq StockUnit.all }
    its([:stock_units]) { are_expected.to all(have_attributes(status: 'PENDING')) }
    its([:stock_units]) { are_expected.to all(be_persisted) }

    describe 'associated stock units' do
      it 'has valid code_greffe' do
        subject
        created_units = stock.stock_units.where(code_greffe: '9721')
          .or(stock.stock_units.where(code_greffe: '9761'))

        expect(created_units).to contain_exactly(
          an_object_having_attributes(code_greffe: '9721'),
          an_object_having_attributes(code_greffe: '9761')
        )
      end

      it 'knows its own path' do
        subject
        unit = stock.stock_units.where(code_greffe: '9761').first

        expect(unit.file_path)
          .to end_with 'spec/fixtures/titmc/stock/2018/05/05/9761_S1_20180505_lot*.zip'
      end

      it 'has a wildcard matching 2 files' do
        subject
        unit = stock.stock_units.where(code_greffe: '9721').first

        expect(unit.file_path)
          .to end_with 'spec/fixtures/titmc/stock/2018/05/05/9721_S1_20180505_lot*.zip'
      end
    end
  end
end
