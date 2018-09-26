require 'rails_helper'

describe Stock do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:year).of_type(:string) }
    it { is_expected.to have_db_column(:month).of_type(:string) }
    it { is_expected.to have_db_column(:day).of_type(:string) }
    it { is_expected.to have_db_column(:files_path).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_many(:stock_units) }
  end

  describe '.current' do
    it 'returns the oldest stock' do
      recent_stock = create(:stock, year: '2018', month: '03', day: '21')
      create(:stock, year: '2016', month: '08', day: '13')

      expect(Stock.current).to eq(recent_stock)
    end
  end

  describe '.first_load?' do
    it 'returns true when no stocks are already imported' do
      Stock.delete_all

      expect(Stock.first_load?).to eq(true)
    end

    it 'is false when a stock is already imported' do
      create(:stock)

      expect(Stock.first_load?).to eq(false)
    end
  end

  describe '#newer?' do
    let(:stock_test) { build(:stock, year: '2017', month: '04', day: '29') }
    subject { stock_test.newer? }

    context 'when the stock is older than the last one imported' do
      before { create(:stock, year: '2018', month: '10', day: '09') }

      it { is_expected.to eq(false) }
    end

    context 'when the stock is newer than the last one imported' do
      before { create(:stock, year: '2016', month: '06', day: '15') }

      it { is_expected.to eq(true) }
    end
  end
end
