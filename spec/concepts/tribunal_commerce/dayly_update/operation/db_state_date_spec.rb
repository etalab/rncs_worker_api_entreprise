require 'rails_helper'

describe TribunalCommerce::DaylyUpdate::Operation::DBStateDate do
  subject { described_class.call }

  context 'when the last dayly update is completed' do
    it 'is success'
    it 'returns the last imported update time'
  end

  context 'when the last dayly update is not completed' do
    it 'fails'
    it 'specifies an error message'
  end

  context 'when no dayly updates have been run yet' do
    context 'when a stock has been imported already' do
      before do
        create(:stock_with_completed_units, year: '2012', month: '03', day: '13')
        create(:stock_with_completed_units, year: '2009', month: '10', day: '17')
      end

      it { is_expected.to be_success }

      it 'returns the last stock date' do
        date_from_last_stock = Date.new(2012, 3, 13)

        expect(subject[:raw_date]).to eq(date_from_last_stock)
      end

      context 'when the stock is not completed' do
        before do
          allow_any_instance_of(StockTribunalCommerce)
            .to receive(:status)
            .and_return('NOT COMPLETED')
        end

        it { is_expected.to be_failure }
        its([:error]) { is_expected.to eq('Current stock import is still running, please import dayly updates when its done.') }
      end
    end

    context 'when no stock have been imported yet' do
      it { is_expected.to be_failure }

      it 'specifies an error message' do
        expect(subject[:error]).to eq('No stock loads into database. Please load last stock available first.')
      end
    end
  end
end
