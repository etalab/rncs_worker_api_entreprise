require 'rails_helper'

describe TribunalInstance::Stock::Operation::Load do
  subject { described_class.call(params) }

  let(:logger) { instance_double(Logger).as_null_object }
  let(:params) { { logger: logger } }

  context 'logger:' do
    it 'logs' do
      expect(logger).to receive(:info).with 'Checking last TITMC stock...'
      subject
    end
  end

  # Stock repository for tests :
  # spec/fixtures/titmc/stock
  # └─ 2018
  #    └─ 05
  #       └─ 05
  #          ├─ 9721_S1_20180505_lot01.zip
  #          ├─ 9721_S1_20180505_lot02.zip
  #          └─ 9761_S1_20180505_lot01.zip
  context 'when stock is found' do
    let(:stock_units) { subject[:stock_units] }

    it { is_expected.to be_success }

    it 'drop db indexes'

    it 'enqueues a job for each greffe found in stock (2 jobs but 3 files)' do
      expect { subject }.to have_enqueued_job(ImportTitmcStockUnitJob)
        .twice
        .on_queue("rncs_worker_api_entreprise_#{Rails.env}_titmc_stock")
    end

    it 'persists unit for greffe 9721 with valid wilcard' do
      subject
      unit = StockUnit.where(code_greffe: '9721').first
      expect(unit.file_path).to eq './spec/fixtures/titmc/stock/2018/05/05/9721_S1_20180505_lot*.zip'
    end

    it 'persists unit for greffe 9761 with valid wildcard' do
      subject
      unit = StockUnit.where(code_greffe: '9761').first
      expect(unit.file_path).to eq './spec/fixtures/titmc/stock/2018/05/05/9761_S1_20180505_lot*.zip'
    end

    it 'has 2 stock units' do
      expect(subject[:stock_units].count).to eq 2
    end

    its([:stock]) { is_expected.to be_persisted }
    its([:stock]) { is_expected.to have_attributes(status: 'PENDING') }

    its([:stock_units]) { are_expected.to all(be_persisted) }
    its([:stock_units]) { are_expected.to all(have_attributes(status: 'PENDING')) }
  end

  shared_examples 'failure that does nothing' do
    it { is_expected.to be_failure }

    it 'does not create any job' do
      expect { subject }.not_to have_enqueued_job ImportTitmcStockUnitJob
    end

    it 'does not persist a stock for import' do
      expect { subject }.not_to change(StockTribunalInstance, :count)
    end
  end

  context 'when current stock already loaded' do
    before { create :stock_titmc_with_pending_units, year: '2018', month: '05', day: '05' }

    it_behaves_like 'failure that does nothing'

    it 'logs "this stock is already loaded"' do
      expect(logger).to receive(:error).with 'No stock newer than 2018-05-05 available ; current stock status: PENDING'
      subject
    end
  end

  # spec/fixtures/titmc/no_stocks_here
  # └─ got_you
  context 'when no stock is found (RetrieveLastStock fails)' do
    before do
      params[:stocks_folder] = Rails.root.join('spec', 'fixtures', 'titmc', 'no_stocks_here')
    end

    it_behaves_like 'failure that does nothing'

    it 'logs an error' do
      expect(logger).to receive(:error)
        .with(/No stock found inside .+ Ensure the folder exists with a valid subfolder structure./)
      subject
    end
  end

  # spec/fixtures/titmc/empty_stocks
  # └─ 2019
  #    └─ 01
  #       └─ 01
  #          └─ it.is.a.trap
  context 'when no stock unit found' do
    before do
      params[:stocks_folder] = Rails.root.join('spec', 'fixtures', 'titmc', 'empty_stocks')
    end

    it { is_expected.to be_failure }

    it 'does not persist a stock for import', pending: 'conception problem but not critical' do
      expect { subject }.not_to change(StockTribunalInstance, :count)
    end

    it 'does not create any job' do
      expect { subject }.not_to have_enqueued_job ImportTitmcStockUnitJob
    end

    it 'logs an error' do
      expect(logger).to receive(:error).with(/No stock units found in .+/)
      subject
    end
  end
end
