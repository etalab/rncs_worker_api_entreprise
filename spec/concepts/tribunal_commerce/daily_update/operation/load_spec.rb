require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::Load do
  # Folder structure for the tests
  # spec/fixtures/tc/flux
  # └── 2018
  #     └── 04
  #         ├── 09
  #         ├── 10
  #         ├── 11
  #         ├── 12
  #         ├── 13
  #         ├── 14
  #         └── 18
  context 'when DBStateDate does not fail' do
    before { create(:daily_update_with_completed_units, year: '2018', month: '04', day: '10') }
    subject { described_class.call }

    it { is_expected.to be_success }

    it 'creates a DailyUpdate record for each new updates found in repo'
    it 'ignores older updates'
    it 'calls import'

    context 'when no daily updates are found in the repo' do
      it 'is failure'
      it 'logs'
    end

    describe 'available options' do
      describe 'delay:' do
        it 'runs only updates older than the number of days provided'
        it 'defaults to 0'
      end

      describe 'limit:' do
        # default to no limit
        it 'limits the number of update to import'
      end
    end
  end

  context 'when DBStateDate fails' do
    it 'is failure'
    it 'logs the returned error message'
  end

  context 'when FetchUpdatesInPipe fails' do
    it 'is failure'
    it 'logs the error message'
  end
end
