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
        create(:daily_update, year: '2015', month: '09', day: '12', proceeded: false)
        create(:daily_update, year: '2015', month: '08', day: '23', proceeded: true)
        create(:daily_update, year: '2008', month: '10', day: '04', proceeded: true)
      end

      it 'returns the last one which has been proceed already' do
        daily_update = described_class.where(year: '2015', month: '08', day: '23').first
        expect(subject).to eq(daily_update)
      end

      context 'when the last imported update is a partial stock' do
        it 'returns the partial stock' do
          partial_stock = create(:daily_update, year: '2015', month: '08', day: '24', partial_stock: true, proceeded: true)

          expect(subject).to eq(partial_stock)
        end
      end

      context 'when both a daily update and a partial stock have been run the same day' do
        it 'returns the daily update' do
          create(:daily_update, year: '2015', month: '08', day: '23', partial_stock: true, proceeded: true)

          expect(subject.date).to eq(Date.new(2015, 8, 23))
          expect(subject).to_not be_a_partial_stock
        end
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

  describe '.next_in_queue' do
    subject { described_class.next_in_queue }

    context 'with queued updates' do
      it 'returns the first one not proceeded' do
        create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '25', proceeded: false)
        create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '27', proceeded: false)

        expect(subject.date).to eq(Date.new(2017, 10, 25))
      end
    end

    context 'with partial stock and daily update queued with the same date' do
      it 'returns the partial stock prior to the daily update' do
        create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '25', proceeded: false, partial_stock: false)
        create(:daily_update_tribunal_commerce, year: '2017', month: '10', day: '25', proceeded: false, partial_stock: true)

        expect(subject.date).to eq(Date.new(2017, 10, 25))
        expect(subject).to be_a_partial_stock
      end
    end

    context 'when queue is empty' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
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

      its(:status) { is_expected.to eq('QUEUED') }
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
