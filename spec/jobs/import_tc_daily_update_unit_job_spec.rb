require 'rails_helper'

describe ImportTCDailyUpdateUnitJob, :trb do
  let(:unit) { create(:daily_update_unit, status: 'PENDING') }
  let(:import_logger) { instance_spy(Logger) }
  subject { described_class.perform_now(unit.id) }

  before do
    # Here we are mocking the specific logger created for the daily
    # update unit import. We can then ensure than this returned logger is
    # given to TribunalCommerce::DailyUpdateUnit::Operation::Load.call
    # as you can see inside `mock_unit_load_operation` method definition
    allow_any_instance_of(DailyUpdateUnit)
      .to receive(:logger_for_import)
      .and_return(import_logger)
  end

  describe 'the component the unit import is delegated to' do
    it 'calls TribunalCommerce::DailyUpdateUnit::Operation::Load for a unit related to a daily update' do
      expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
        .to receive(:call)
        .with({ daily_update_unit: unit, logger: import_logger })
        .and_return(trb_result_success)

      subject
    end

    it 'calls TribunalCommerce::PartialStockUnit::Operation::Load for a unit related to a partial stock' do
      unit.daily_update.update(partial_stock: true)
      expect(TribunalCommerce::PartialStockUnit::Operation::Load)
        .to receive(:call)
        .with({ daily_update_unit: unit, logger: import_logger })
        .and_return(trb_result_success)

      subject
    end
  end

  # A daily update unit is used for the following specs
  context 'when the unit import is successful' do
    before { mock_unit_load_operation(trb_result_success) }

    it 'sets the unit\'s status to "COMPLETED"' do
      subject
      unit.reload

      expect(unit.status).to eq('COMPLETED')
    end

    it 'calls PostImport' do
      expect(TribunalCommerce::DailyUpdateUnit::Operation::PostImport)
        .to receive(:call)
        .with(daily_update_unit: unit)
      subject
    end
  end

  context 'when the unit import fails' do
    it 'rollbacks everything written in database' do
      expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
        .to receive(:call)
        .and_wrap_original do |original_method, *args|
        # Write into DB as if the operation did
        create(:daily_update_unit, status: 'GHOST')
        trb_result_failure
      end

      subject

      ghost = DailyUpdateUnit.where(status: 'GHOST')
      expect(ghost).to be_empty
    end

    it 'sets the unit\'s status to "ERROR"' do
      mock_unit_load_operation(trb_result_failure)
      subject
      unit.reload

      expect(unit.status).to eq('ERROR')
    end
  end

  def mock_unit_load_operation(result)
    expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
      .to receive(:call)
      .with({ daily_update_unit: unit, logger: import_logger })
      .and_return(result)
  end
end
