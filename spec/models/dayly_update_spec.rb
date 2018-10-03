require 'rails_helper'

describe DaylyUpdate do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:year).of_type(:string) }
    it { is_expected.to have_db_column(:month).of_type(:string) }
    it { is_expected.to have_db_column(:day).of_type(:string) }
    it { is_expected.to have_db_column(:files_path).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_many(:dayly_update_units) }
  end

  describe '.current' do
    subject { described_class.current }

    context 'when dayly updates have been imported already' do
      before do
        create(:dayly_update, year: '2015', month: '08', day: '23')
        create(:dayly_update, year: '2008', month: '10', day: '04')
      end

      it 'returns the last one in date' do
        dayly_update = described_class.where(year: '2015', month: '08', day: '23').first
        expect(subject).to eq(dayly_update)
      end
    end

    context 'when no dayly updates have been imported' do
      it { is_expected.to eq(nil) }
    end
  end

  describe '#status' do
    subject { create(dayly_update_param) }

    context 'when all units children are pending' do
      let(:dayly_update_param) { :dayly_update_with_pending_units }

      its(:status) { is_expected.to eq('PENDING') }
    end

    context 'when at least one unit child is loading' do
      let(:dayly_update_param) { :dayly_update_with_one_loading_unit }

      its(:status) { is_expected.to eq('LOADING') }
    end

    context 'when at least one unit child ended in error ' do
      let(:dayly_update_param) { :dayly_update_with_one_error_unit }

      its(:status) { is_expected.to eq('ERROR') }
    end

    context 'when all units children are completed' do
      let(:dayly_update_param) { :dayly_update_with_completed_units }

      its(:status) { is_expected.to eq('COMPLETED') }
    end
  end
end
