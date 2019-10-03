require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::FetchInPipe do
  context 'when no updates are found' do
    shared_examples 'no update found' do |source_path|
      subject { described_class.call(flux_folder: source_path) }
      it { is_expected.to be_failure }

      it 'sets an error message' do
        message = "No daily updates found inside #{source_path}. Ensure the folder exists with a valid subfolder structure."
        expect(subject[:error]).to eq(message)
      end
    end

    context 'when repository is empy' do
      empty_dir = Rails.root.join('spec', 'fixtures', 'tc', 'no_stock_here', 'got_you')
      it_behaves_like 'no update found', empty_dir
    end

    context 'when updates are not recognized' do
      falsey_updates = Rails.root.join('spec', 'fixtures', 'tc', 'no_stock_here')
      it_behaves_like 'no update found', falsey_updates
    end
  end

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
  context 'when updates are found' do
    let(:source_path) { Rails.root.join('spec', 'fixtures', 'tc', 'flux') }
    subject { described_class.call(flux_folder: source_path) }

    it { is_expected.to be_success }

    it 'returns all daily updates as records' do
      updates = subject[:daily_updates]

      expect(updates).to all(be_an_instance_of(DailyUpdateTribunalCommerce))
      expect(updates).to all(have_attributes(partial_stock?: false))
      expect(updates.size).to eq(7)
    end

    it 'matches the dates found in repository' do
      expect(subject[:daily_updates]).to contain_exactly(
        an_object_having_attributes(year: '2018', month: '04', day: '09'),
        an_object_having_attributes(year: '2018', month: '04', day: '10'),
        an_object_having_attributes(year: '2018', month: '04', day: '11'),
        an_object_having_attributes(year: '2018', month: '04', day: '12'),
        an_object_having_attributes(year: '2018', month: '04', day: '13'),
        an_object_having_attributes(year: '2018', month: '04', day: '14'),
        an_object_having_attributes(year: '2018', month: '04', day: '18')
      )
    end
  end
end
