require 'rails_helper'

describe ImportTcDailyUpdateUnitJob do
  let(:result_class) { Trailblazer::Operation::Railway::Result }
  let(:unit) { create(:daily_update_unit, status: 'PENDING') }
  subject { described_class.perform_now(unit.id) }

  context 'when the unit import is successful' do
    let(:operation_result) { instance_double(result_class, success?: true) }

    before do
      mock_unit_load_operation(operation_result)
      expect(TribunalCommerce::DailyUpdateUnit::Operation::PostImport)
        .to receive(:call)
        .with({ daily_update_unit: unit })
    end

    it 'sets the unit\'s status to "COMPLETED"' do
      subject
      unit.reload

      expect(unit.status).to eq('COMPLETED')
    end

    it 'calls PostImport' do
      subject
    end
  end

  context 'when the unit import fails' do
    let(:operation_result) { instance_double(result_class, success?: false) }

    it 'rollbacks everything written in database' do
      expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
        .to receive(:call)
        .and_wrap_original do |original_method, *args|
        # Write into DB as if the operation did
        create(:daily_update_unit, status: 'GHOST')
        operation_result
      end

      subject

      ghost = DailyUpdateUnit.where(status: 'GHOST')
      expect(ghost).to be_empty
    end

    it 'sets the unit\'s status to "ERROR"' do
      mock_unit_load_operation(operation_result)
      subject
      unit.reload

      expect(unit.status).to eq('ERROR')
    end
  end

  def mock_unit_load_operation(result)
    expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
      .to receive(:call)
      .with({ daily_update_unit: unit })
      .and_return(result)
  end
end
