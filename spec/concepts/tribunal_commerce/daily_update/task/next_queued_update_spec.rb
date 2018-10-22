require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Task::NextQueuedUpdate do
  subject { described_class.call }

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
      its([:error]) { is_expected.to eq("No queued update after 2017-10-24.") }
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
