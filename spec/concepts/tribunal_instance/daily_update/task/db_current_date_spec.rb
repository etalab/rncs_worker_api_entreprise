require 'rails_helper'

describe TribunalInstance::DailyUpdate::Task::DBCurrentDate do
  subject { described_class.call logger: logger }

  let(:logger) { instance_double(Logger).as_null_object }

  describe 'success' do
    describe 'when there is no daily update yet' do
      it { is_expected.to be_success }
      its([:db_current_date]) { is_expected.to be_nil }

      it 'logs' do
        expect(logger).to receive(:info).with('No existing daily update found, proceeding...')

        subject
      end
    end

    describe 'when every daily updates are completed' do
      before do
        create :daily_update_titmc_with_completed_units, year: '2018', month: '12', day: '31'
        create :daily_update_titmc_with_completed_units, year: '2019', month: '01', day: '02'
      end

      it { is_expected.to be_success }
      its([:db_current_date]) { is_expected.to eq Date.new 2019, 1, 2 }
    end
  end

  describe 'failure' do
    context 'when daily updates are waiting for import' do
      before { create :daily_update_titmc_with_pending_units, proceeded: false }

      it { is_expected.to be_failure }

      it 'logs an error' do
        expect(logger).to receive(:error).with('Pending daily updates found in database. Aborting...')
        subject
      end
    end

    context 'when last daily update is not completed' do
      before { create :daily_update_titmc_with_one_loading_unit }

      it { is_expected.to be_failure }

      it 'logs an error' do
        expect(logger).to receive(:error).with('The current update is still running. Aborting...')
        subject
      end
    end
  end
end
