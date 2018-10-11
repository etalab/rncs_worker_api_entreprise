require 'rails_helper'

describe ImportTcDailyUpdateUnitJob do
  let(:result_class) { Trailblazer::Operation::Railway::Result }
  let(:unit) { create(:daily_update_unit, status: 'PENDING') }
  subject { described_class.perform_now(unit.id) }

  before do
    expect(TribunalCommerce::DailyUpdateUnit::Operation::Load)
      .to receive(:call)
      .with({ daily_update_unit: unit })
      .and_return(operation_result)
  end

  context 'when the unit import is successful' do
    let(:operation_result) { instance_double(result_class, success?: true) }

    it 'sets the unit\'s status to "COMPLETED"' do
      subject
      unit.reload

      expect(unit.status).to eq('COMPLETED')
    end

    it 'calls PostImport' do
      expect(TribunalCommerce::DailyUpdateUnit::Operation::PostImport)
        .to receive(:call)

      subject
    end
  end

  context 'when the unit import fails' do
    let(:operation_result) { instance_double(result_class, success?: false) }

    it 'sets the unit\'s status to "ERROR"' do
      subject
      unit.reload

      expect(unit.status).to eq('ERROR')
    end
  end
end
