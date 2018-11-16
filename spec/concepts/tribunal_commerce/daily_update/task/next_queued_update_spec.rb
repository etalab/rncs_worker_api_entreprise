require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Task::NextQueuedUpdate do
  subject { described_class.call }

  context 'when no daily updates have been run yet' do
    context 'when a stock is successfuly imported' do
      before { create(:stock_with_completed_units, year: '2017', month: '10', day: '23') }

      context 'with queued updates' do
        before do
          create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '25', proceeded: false)
          create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '27', proceeded: false)
          create(:daily_update_tribunal_commerce, year: '2017', month: '11', day: '03', proceeded: false)
        end

        it 'returns the first update in queue' do
          update = subject[:daily_update]

          expect(update.date). to eq(Date.new(2017, 10, 25))
        end

        it { is_expected.to be_success }
      end

      context 'with no queued updates yet' do
        its([:error]) { is_expected.to eq('No updates have been queued for import.') }

        it { is_expected.to be_failure }
      end
    end

    context 'when no stock have been imported yet' do
      its([:error]) { is_expected.to eq('No stock has been fully imported yet. Aborting...') }

      it { is_expected.to be_failure }
    end
  end

  context 'when daily updates have already been run' do
    context 'when last update was sucessfully imported' do
      before do
        create(:daily_update_with_completed_units, year: '2017', month: '10', day: '24', proceeded: true)
      end

      context 'with queued updates' do
        before do
          create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '25', proceeded: false)
          create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '27', proceeded: false)
        end

        it { is_expected.to be_success }

        it 'returns the first update in queue' do
          update = subject[:daily_update]

          expect(update.date). to eq(Date.new(2017, 10, 25))
        end
      end

      context 'when no updates have been queued' do
        it { is_expected.to be_failure }
        its([:error]) { is_expected.to eq('No updates have been queued for import.') }
      end
    end

    context 'when current update is not completed' do
      before do
        create(:daily_update_with_one_error_unit, year: '2017', month: '10', day: '24', proceeded: true)
      end

      it { is_expected.to be_failure }
      its([:error]) { is_expected.to eq("The last update 2017-10-24 is not completed. Aborting import...") }
    end
  end
end
