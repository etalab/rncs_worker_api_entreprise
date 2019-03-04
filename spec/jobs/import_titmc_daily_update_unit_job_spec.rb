require 'rails_helper'

describe ImportTitmcDailyUpdateUnitJob, :trb do
  subject { described_class.perform_now unit_id }

  let(:logger) { instance_double(Logger).as_null_object }

  before do
    allow_any_instance_of(DailyUpdateUnit)
      .to receive(:logger_for_import)
      .and_return(logger)
  end

  context 'when unit is found' do
    let(:unit) { create :daily_update_unit }
    let(:unit_id) { unit.id }

    describe 'job is successful' do
      it 'calls the Load operation' do
        expect(TribunalInstance::DailyUpdate::Unit::Operation::Load)
          .to receive(:call)
          .with(daily_update_unit: unit, logger: logger)
          .and_return(trb_result_success)

        subject
      end

      describe 'when Load operation is successful' do
        before do
          allow(TribunalInstance::DailyUpdate::Unit::Operation::Load)
            .to receive(:call)
            .with(daily_update_unit: unit, logger: logger)
            .and_return(trb_result_success)
        end

        it 'set unit status to COMPLETED' do
          subject
          unit.reload
          expect(unit.status).to eq 'COMPLETED'
        end

        it 'calls the DailyUpdate::Import operation' do
          expect(TribunalInstance::DailyUpdate::Operation::Import)
            .to receive(:call)
            .with(logger: logger)

          subject
        end
      end
    end

    describe 'when Load operation fails' do
      before do
        allow(TribunalInstance::DailyUpdate::Unit::Operation::Load)
          .to receive(:call)
          .with(daily_update_unit: unit, logger: logger)
          .and_wrap_original {
            create :daily_update_unit, status: 'GHOST'
            trb_result_failure
          }
      end

      it 'rollbacks database' do
        subject
        ghost = DailyUpdateUnit.where(status: 'GHOST')
        expect(ghost).to be_empty
      end

      it 'set unit status to ERROR' do
        subject
        unit.reload
        expect(unit.status).to eq 'ERROR'
      end

      it 'does not call DailyUpdate::Import operation' do
        expect(TribunalInstance::DailyUpdate::Operation::Import)
          .not_to receive(:call)

        subject
      end
    end
  end

  describe 'when some units are not completed' do
    let(:daily_update) { create :daily_update_titmc_with_pending_units }
    let(:unit) { create :daily_update_unit, daily_update: daily_update }
    let(:unit_id) { unit.id }

    before do
      allow(TribunalInstance::DailyUpdate::Unit::Operation::Load)
        .to receive(:call)
        .with(daily_update_unit: unit, logger: logger)
        .and_return(trb_result_success)
    end

    it 'does not call DailyUpdate::Import' do
      expect(TribunalInstance::DailyUpdate::Operation::Import)
        .not_to receive(:call)

      subject
    end
  end

  context 'when unit is not found' do
    let(:unit_id) { '1234' }

    it 'does not call the Load operation' do
      expect(TribunalInstance::DailyUpdate::Unit::Operation::Load)
        .not_to receive(:call)
      subject
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with('Couldn\'t find DailyUpdateUnit with \'id\'=1234')
      subject
    end
  end
end
