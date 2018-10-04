require 'rails_helper'

describe DailyUpdate do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:year).of_type(:string) }
    it { is_expected.to have_db_column(:month).of_type(:string) }
    it { is_expected.to have_db_column(:day).of_type(:string) }
    it { is_expected.to have_db_column(:files_path).of_type(:string) }
    it { is_expected.to have_db_column(:proceeded).of_type(:boolean) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_many(:daily_update_units) }
  end

  describe '.current' do
    subject { described_class.current }

    context 'when daily updates have been imported already' do
      before do
        create(:daily_update, year: '2015', month: '08', day: '23')
        create(:daily_update, year: '2008', month: '10', day: '04')
      end

      it 'returns the last one in date' do
        daily_update = described_class.where(year: '2015', month: '08', day: '23').first
        expect(subject).to eq(daily_update)
      end
    end

    context 'when no daily updates have been imported' do
      it { is_expected.to eq(nil) }
    end
  end

  describe '.queued_updates?' do
    subject { described_class.queued_updates? }

    it 'is true when daily updates are waiting to be proceed' do
      create(:daily_update, proceeded: false)

      expect(subject).to eq(true)
    end

    it 'is false when all known updates have been run already' do
      create(:daily_update, proceeded: true)

      expect(subject).to eq(false)
    end
  end

  describe '#date' do
    subject { create(:daily_update, year: '2018', month: '05', day: '24') }

    it 'returns the corresponding Date object' do
      expect(subject.date).to eq(Date.new(2018, 5, 24))
    end
  end

  describe '#newer?' do
    subject { build(:daily_update, year: '2017', month: '09', day: '11') }

    it 'is true when given date is older' do
      older_date = Date.new(2017, 6, 23)

      expect(subject.newer?(older_date)).to eq(true)
    end

    it 'is false when given date equals record\'s date' do
      same_date = subject.date

      expect(subject.newer?(same_date)).to eq(false)
    end

    it 'is false when given date is more recent' do
      newer_date = Date.new(2018, 2, 18)

      expect(subject.newer?(newer_date)).to eq(false)
    end
  end

  describe '#status' do
    subject { create(daily_update_param) }

    context 'when there are no childs yet' do
      let(:daily_update_param) { :daily_update_tribunal_commerce }

      its(:status) { is_expected.to eq('PENDING') }
    end

    context 'when all units children are pending' do
      let(:daily_update_param) { :daily_update_with_pending_units }

      its(:status) { is_expected.to eq('PENDING') }
    end

    context 'when at least one unit child is loading' do
      let(:daily_update_param) { :daily_update_with_one_loading_unit }

      its(:status) { is_expected.to eq('LOADING') }
    end

    context 'when at least one unit child ended in error ' do
      let(:daily_update_param) { :daily_update_with_one_error_unit }

      its(:status) { is_expected.to eq('ERROR') }
    end

    context 'when all units children are completed' do
      let(:daily_update_param) { :daily_update_with_completed_units }

      its(:status) { is_expected.to eq('COMPLETED') }
    end
  end
end
