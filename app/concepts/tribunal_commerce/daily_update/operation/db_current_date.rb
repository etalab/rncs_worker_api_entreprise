module TribunalCommerce
  module DailyUpdate
    module Operation
      class DBCurrentDate < Trailblazer::Operation
        step :find_latest_completed_update, Output(:failure) => Track(:no_daily_updates_yet)
        step :raw_daily_update_date

        step :current_stock, magnetic_to: [:no_daily_updates_yet], Output(:success) => Track(:no_daily_updates_yet)
        fail :log_empty_db, fail_fast: true
        step :stock_completed?, magnetic_to: [:no_daily_updates_yet], Output(:success) => Track(:no_daily_updates_yet)
        fail :log_incomplete_stock, fail_fast: true
        step :raw_stock_date, magnetic_to: [:no_daily_updates_yet], Output(:success) => 'End.success'

        def find_latest_completed_update(ctx, **)
          ctx[:current_daily_update] = DailyUpdateTribunalCommerce.last_completed
        end

        def raw_daily_update_date(ctx, current_daily_update:, **)
          ctx[:db_current_date] = current_daily_update.date
        end

        def current_stock(ctx, **)
          ctx[:current_stock] = StockTribunalCommerce.current
        end

        def stock_completed?(_, current_stock:, **)
          current_stock.status == 'COMPLETED'
        end

        def raw_stock_date(ctx, current_stock:, **)
          ctx[:db_current_date] = current_stock.date
        end

        def log_empty_db(ctx, **)
          ctx[:error] = 'No updates or stocks load into database. Please load last stock available first.'
        end

        def log_incomplete_stock(ctx, **)
          ctx[:error] = 'Current stock import is still running, please import daily updates when its done.'
        end
      end
    end
  end
end
