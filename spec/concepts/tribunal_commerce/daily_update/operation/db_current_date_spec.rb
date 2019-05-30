require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::DBCurrentDate do
  subject { described_class.call }

  # TODO Deal with partial stocks
  # Factories should be genric DailyUpdates
  context 'when successful daily updates are found' do
    before do
      create(:daily_update_with_completed_units, year: '2012', month: '03', day: '13')
      create(:daily_update_with_completed_units, year: '2015', month: '09', day: '27')
    end

    shared_examples 'returning the date of last successful daily update' do
      it { is_expected.to be_success }

      it 'returns the date of the last one' do
        expect(subject[:db_current_date]).to eq(Date.new(2015, 9, 27))
      end
    end

    context 'when all daily updates have been successfully imported' do
      it_behaves_like 'returning the date of last successful daily update'
    end

    context 'when daily updates are pending' do
      before do
        create(:daily_update_with_pending_units, year: '2015', month: '09', day: '28')
        create(:daily_update_with_pending_units, year: '2015', month: '09', day: '30')
      end

      it_behaves_like 'returning the date of last successful daily update'
    end

    context 'when one daily update is running' do
      before { create(:daily_update_with_one_loading_unit, year: '2015', month: '09', day: '28') }

      it_behaves_like 'returning the date of last successful daily update'
    end

    context 'when the last daily update is in error' do
      before { create(:daily_update_with_one_error_unit, year: '2015', month: '09', day: '28') }

      it_behaves_like 'returning the date of last successful daily update'
    end
  end

  context 'when no successful daily updates are found' do
    before { create(:daily_update_with_pending_units, year: '2015', month: '09', day: '28') }

    context 'when a stock has been successfully imported already' do
      before do
        create(:stock_tc_with_completed_units, year: '2012', month: '03', day: '13')
        create(:stock_tc_with_completed_units, year: '2009', month: '10', day: '17')
      end

      it { is_expected.to be_success }

      it 'returns the last stock date' do
        date_from_last_stock = Date.new(2012, 3, 13)

        expect(subject[:db_current_date]).to eq(date_from_last_stock)
      end

      context 'when the stock is not completed' do
        before do
          allow_any_instance_of(StockTribunalCommerce)
            .to receive(:status)
            .and_return('NOT COMPLETED')
        end

        it { is_expected.to be_failure }

        its([:error]) { is_expected.to eq('Current stock import is still running, please import daily updates when its done.') }
      end
    end

    context 'when no stock have been imported yet' do
      it { is_expected.to be_failure }

      it 'specifies an error message' do
        expect(subject[:error]).to eq('No updates or stocks load into database. Please load last stock available first.')
      end
    end
  end
end
