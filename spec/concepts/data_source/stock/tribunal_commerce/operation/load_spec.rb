require 'rails_helper'

# TODO log step or errors in environment.log file
describe DataSource::Stock::TribunalCommerce::Operation::Load do
  subject { described_class.call(stocks_folder: example_stock_folder) }
  let(:new_stock) { subject[:stock] }

  context 'when a stock is available for import' do
    let(:example_stock_folder) { Rails.root.join('spec', 'fixtures', 'tc', 'stock') }
    before do
      Stock.delete_all
      StockUnit.delete_all
    end

    it { is_expected.to be_success }

    it 'drops db indexes'

    it 'creates a job to import each stock unit' do
      # TODO ? pass stock_unit model global id to the job
      stock_unit_ids = new_stock.stock_units.pluck(:id)

      stock_unit_ids.each do |id|
        expect(ImportTcStockUnitJob)
          .to have_been_enqueued.with(id).on_queue("rncs_worker_api_entreprise_#{Rails.env}_tc_stock")
      end
    end

    it 'saves the new stock with status "PENDING"' do
      expect(new_stock.status).to eq('PENDING')
      expect(new_stock).to be_persisted
    end

    it 'saves each associated stock units with status "PENDING"' do
      stock_units = new_stock.stock_units.where(status: 'PENDING')

      expect(stock_units.size).to eq(3)
    end
  end

  context 'when no stock is found' do
    let(:example_stock_folder) { Rails.root.join('spec', 'fixtures', 'tc', 'no_stocks_here') }

    it { is_expected.to be_failure }

    it 'creates no job for stock unit import' do
      expect { subject }.to_not have_enqueued_job(ImportTcStockUnitJob)
    end

    it 'does not save a new stock' do
      expect { subject }.to_not change(StockTribunalCommerce, :count)
    end
  end

  context 'when stocks found are older than the last one imported' do
    let(:example_stock_folder) { Rails.root.join('spec', 'fixtures', 'tc', 'stock') }
    before { create(:stock_tribunal_commerce, year: '2018', month: '10', day: '13') }

    it { is_expected.to be_failure }

    it 'creates no job for stock unit import' do
      expect { subject }.to_not have_enqueued_job(ImportTcStockUnitJob)
    end

    it 'does not save a new stock' do
      expect { subject }.to_not change(StockTribunalCommerce, :count)
    end
  end

  context 'when last stock saved in DB is not completed' do
    it 'does not do anything'
  end
end
