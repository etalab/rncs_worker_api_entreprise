require 'rails_helper'

describe TribunalInstance::DailyUpdate::Task::FetchInPipe do
  context 'when no updates are found' do
    shared_examples 'no update found' do |source_path|
      subject { described_class.call(flux_folder: source_path) }
      it { is_expected.to be_failure }

      it 'sets an error message' do
        expect(subject[:error]).to eq(
          "No daily updates found inside #{source_path}. Ensure the folder exists with a valid subfolder structure."
        )
      end
    end

    context 'when repository is empy' do
      empty_dir = Rails.root.join('spec', 'fixtures', 'titmc', 'no_stock_here', 'got_you')
      it_behaves_like 'no update found', empty_dir
    end

    context 'when updates are not recognized' do
      falsey_updates = Rails.root.join('spec', 'fixtures', 'titmc', 'no_stock_here')
      it_behaves_like 'no update found', falsey_updates
    end
  end

  # spec/fixtures/titmc/flux
  # └── 2017
  #     └── 05
  #         ├── 18
  #         ├── 19
  #         ├── 20
  #         ├── 23
  #         ├── 24
  #         └── 25
  context 'when updates are found' do
    subject { described_class.call(flux_folder: source_path) }

    let(:source_path) { Rails.root.join('spec', 'fixtures', 'titmc', 'flux') }

    it { is_expected.to be_success }

    it 'returns all daily updates as records' do
      updates = subject[:daily_updates]

      expect(updates).to all be_an_instance_of DailyUpdateTribunalInstance
      expect(updates.size).to eq 6
    end

    it 'matches the dates found in repository' do
      expect(subject[:daily_updates]).to contain_exactly(
        an_object_having_attributes(year: '2017', month: '05', day: '18'),
        an_object_having_attributes(year: '2017', month: '05', day: '19'),
        an_object_having_attributes(year: '2017', month: '05', day: '20'),
        an_object_having_attributes(year: '2017', month: '05', day: '23'),
        an_object_having_attributes(year: '2017', month: '05', day: '24'),
        an_object_having_attributes(year: '2017', month: '05', day: '25')
      )
    end
  end
end
