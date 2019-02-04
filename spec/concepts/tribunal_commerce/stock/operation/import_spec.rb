require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_change, :change

describe TribunalCommerce::Stock::Operation::Import do
  let(:stock_args) { { year: '2017', month: '01', day: '28' } }
  let(:logger) { spy(Rails.logger) }

  subject { described_class.call(stock_args: stock_args, stocks_folder: fixture_path, logger: logger) }

  it 'logs the operation start fetching the specified stock' do
    stock_name = "#{stock_args[:year]}/#{stock_args[:month]}/#{stock_args[:day]}"
    subject

    expect(logger).to have_received(:info)
      .with("Starting import : looking for stock #{stock_name} in file system...")
  end

  # Fixture stock folder contains three units :
  # spec/fixtures/tc/stock/2017/01/28
  # ├── 0121_S1_20170128.zip
  # ├── 1001_S1_20170128.zip
  # └── 5432_S1_20170128.zip
  context 'when the specified stock is found in the file system' do
    let(:fixture_path) { Rails.root.join('spec/fixtures/tc/stock') }
    let(:new_stock) { subject[:new_stock] }

    it { is_expected.to be_success }

    it 'drops db indexes' do
      expect_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        .to receive(:execute)
        .exactly(expected_drop_query_count).times
      subject
    end

    it 'creates a job to import each stock unit' do
      stock_unit_ids = new_stock.stock_units.pluck(:id)

      stock_unit_ids.each do |id|
        expect(ImportTcStockUnitJob)
          .to have_been_enqueued.with(id).on_queue("rncs_worker_api_entreprise_#{Rails.env}_tc_stock")
      end
    end

    it 'creates a StockTribunalCommerce with status "PENDING"' do
      expect(new_stock).to be_persisted
      expect(new_stock).to be_an_instance_of(StockTribunalCommerce)
      expect(new_stock).to have_attributes(
        year: '2017',
        month: '01',
        day: '28',
        files_path: a_string_ending_with('tc/stock/2017/01/28')
      )
    end

    it 'saves each associated stock units with status "PENDING"' do
      stock_units = new_stock.stock_units

      expect(stock_units.size).to eq(3)
      expect(stock_units).to all(have_attributes(status: 'PENDING'))
    end

    it 'logs jobs are created for import' do
      subject

      expect(logger).to have_received(:info)
        .with('Creating jobs to import each greffe\'s unit synchronously...')
    end

    context 'when stock units name are unexpected' do
      it 'is failure'
      it 'logs irregular units name are found'
      it 'does not save any stocks or units in database'
    end

    def expected_drop_query_count
      indexes_table = Rails.application.config_for(:db_indexes)
      indexes_count = indexes_table.inject(0) { |sum, array| sum + array[1].count }

      others_operations_count = 8

      indexes_count + others_operations_count
    end
  end

  context 'when the specified stock is not found' do
    let(:fixture_path) { Rails.root.join('spec/fixtures/tc/no_stocks_here') }

    it { is_expected.to be_failure }

    it 'creates no job for stock unit import' do
      expect { subject }.to_not have_enqueued_job(ImportTcStockUnitJob)
    end

    it 'does not save any stocks or units in database' do
      expect { subject }.to not_change(StockTribunalCommerce, :count)
        .and(not_change(StockUnit, :count))
    end

    it 'logs the stock is not found' do
      relative_stock_path = "#{stock_args[:year]}/#{stock_args[:month]}/#{stock_args[:day]}"
      stock_path = File.join(fixture_path, relative_stock_path)
      subject

      expect(logger).to have_received(:error)
        .with("Specified stock #{stock_path} is not found. Ensure the stock to import exists. Aborting...")
    end
  end
end
