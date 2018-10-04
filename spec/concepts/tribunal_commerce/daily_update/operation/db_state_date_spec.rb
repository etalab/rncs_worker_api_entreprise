require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::DBStateDate do
  subject { described_class.call }

  context 'when daily updates are waiting for import' do
    before { create_list(:daily_update_with_pending_units, 2, proceeded: false) }

    it { is_expected.to be_failure }
    its([:error]) { is_expected.to eq('Pending daily updates found in database. Aborting... Please import remaining updates first.') }
  end

  context 'when every daily updates have been imported' do
    context 'when the last daily update is completed' do
      before do
        create(:daily_update_with_completed_units, year: '2012', month: '03', day: '13')
        create(:daily_update_with_completed_units, year: '2015', month: '09', day: '27')
      end

      it { is_expected.to be_success }

      it 'returns the last imported update time' do
        expect(subject[:raw_date]).to eq(Date.new(2015, 9, 27))
      end
    end

    context 'when the last daily update is not completed' do
      before { create(:daily_update_with_one_loading_unit) }

      it { is_expected.to be_failure }

      its([:error]) { is_expected.to eq('The current update is still running. Abort...') }
    end

    context 'when no daily updates have been run yet' do
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
          its([:error]) { is_expected.to eq('Current stock import is still running, please import daily updates when its done.') }
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
end
