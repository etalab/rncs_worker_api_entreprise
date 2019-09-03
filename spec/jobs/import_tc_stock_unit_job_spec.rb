require 'rails_helper'

describe ImportTCStockUnitJob, :trb do
  let(:unit) { create(:stock_unit, status: 'PENDING') }
  let(:logger) { instance_spy(Logger) }

  subject { described_class.perform_now(unit.id) }

  # Here we mock the logger associated to the unit
  # This is to ensure it is then given to the unit import operation
  # TODO Actually now that we pass the entire unit instance to the operation
  # the logger can be retrieved from it, it's not needed as a parameter anymore
  # Logging system must be refactor using Dry Container anyway
  before { allow_any_instance_of(StockUnit).to receive(:logger_for_import).and_return(logger) }

  it 'calls the TribunalCommerce::StockUnit::Operation::Load operation' do
    allow(TribunalCommerce::StockUnit::Operation::Load)
      .to receive(:call)
      .with({ stock_unit: unit, logger: logger })
      .and_return(trb_result_success)

    subject
  end

  context 'when the unit import is successful' do
    before do
      allow(TribunalCommerce::StockUnit::Operation::Load)
        .to receive(:call)
        .with({ stock_unit: unit, logger: logger })
        .and_return(trb_result_success)
    end

    it 'sets the unit\'s status to "COMPLETED"' do
      subject
      unit.reload

      expect(unit.status).to eq('COMPLETED')
    end

    it 'calls PostImport operation' do
      expect(TribunalCommerce::Stock::Operation::PostImport)
        .to receive(:call)
        .with(stock_unit: unit)

      subject
    end
  end

  context 'when the unit import fails' do
    it 'rollbacks everything written in database' do
      expect(TribunalCommerce::StockUnit::Operation::Load)
        .to receive(:call)
        .and_wrap_original do |original_method, *args|
        # Write into DB as if the operation did
        create(:stock_unit, status: 'GHOST')
        trb_result_failure
      end

      subject

      ghost = StockUnit.where(status: 'GHOST')
      expect(ghost).to be_empty
    end

    it 'sets the unit\'s status to "ERROR"' do
      allow(TribunalCommerce::StockUnit::Operation::Load)
        .to receive(:call)
        .with({ stock_unit: unit, logger: logger })
        .and_return(trb_result_failure)
      subject
      unit.reload

      expect(unit.status).to eq('ERROR')
    end
  end
end
