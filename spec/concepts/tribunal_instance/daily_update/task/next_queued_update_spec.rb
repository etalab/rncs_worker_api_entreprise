require 'rails_helper'

describe TribunalInstance::DailyUpdate::Task::NextQueuedUpdate do
  subject { described_class.call(logger: logger) }

  let(:logger) { instance_double(Logger).as_null_object }

  context 'when no daily updates have been run yet' do
    context 'with queued updates' do
      before do
        create :daily_update_tribunal_instance, year: '2017', month: '10', day: '25', proceeded: false
        create :daily_update_tribunal_instance, year: '2017', month: '10', day: '27', proceeded: false
      end

      it { is_expected.to be_success }

      it 'returns the first update in queue' do
        update = subject[:daily_update]
        expect(update.date). to eq(Date.new(2017, 10, 25))
      end
    end

    context 'with no queued updates yet' do
      it { is_expected.to be_failure }

      it 'logs an error' do
        expect(logger).to receive(:error).with('No updates have been queued for import.')
        subject
      end
    end
  end

  context 'when daily updates have already been run' do
    context 'when last update was sucessfully imported' do
      before do
        create :daily_update_titmc_with_completed_units, year: '2017', month: '10', day: '24', proceeded: true
      end

      context 'with queued daily updates only' do
        before do
          create :daily_update_tribunal_instance, year: '2017', month: '10', day: '25', proceeded: false
          create :daily_update_tribunal_instance, year: '2017', month: '10', day: '27', proceeded: false
        end

        it { is_expected.to be_success }

        it 'returns the first update in queue' do
          update = subject[:daily_update]
          expect(update.date). to eq(Date.new(2017, 10, 25))
        end
      end

      context 'when no updates have been queued' do
        it { is_expected.to be_failure }

        it 'logs an error' do
          expect(logger).to receive(:error).with('No updates have been queued for import.')
          subject
        end
      end
    end

    context 'when current update is not completed' do
      before do
        create :daily_update_titmc_with_one_loading_unit, year: '2017', month: '10', day: '24', proceeded: true
      end

      it { is_expected.to be_failure }

      it 'logs an error' do
        expect(logger).to receive(:error).with('The last update 2017-10-24 is not completed. Aborting import...')
        subject
      end
    end
  end
end
