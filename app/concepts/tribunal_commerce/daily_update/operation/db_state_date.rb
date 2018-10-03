module TribunalCommerce
  module DailyUpdate
    module Operation
      class DBStateDate < Trailblazer::Operation
        step :current_daily_update, Output(:failure) => Track(:no_daily_updates)
        step :daily_update_completed?
        fail :log_incomplete_update, fail_fast: true
        step :raw_daily_update_date

        step :current_stock, magnetic_to: [:no_daily_updates], Output(:success) => Track(:no_daily_updates)
        fail :log_empty_db, fail_fast: true
        step :stock_completed?, magnetic_to: [:no_daily_updates], Output(:success) => Track(:no_daily_updates)
        fail :log_incomplete_stock, fail_fast: true
        step :raw_stock_date, magnetic_to: [:no_daily_updates], Output(:success) => 'End.success'


        def current_daily_update(ctx, **)
          ctx[:current_daily_update] = DailyUpdateTribunalCommerce.current
        end

        def daily_update_completed?(ctx, current_daily_update:, **)
          current_daily_update.status == 'COMPLETED'
        end

        def raw_daily_update_date(ctx, current_daily_update:, **)
          ctx[:raw_date] = current_daily_update.date
        end

        def current_stock(ctx, **)
          ctx[:current_stock] = StockTribunalCommerce.current
        end

        def stock_completed?(ctx, current_stock:, **)
          current_stock.status == 'COMPLETED'
        end

        def raw_stock_date(ctx, current_stock:, **)
          ctx[:raw_date] = current_stock.date
        end

        def log_empty_db(ctx, **)
          ctx[:error] = 'No stock loads into database. Please load last stock available first.'
        end

        def log_incomplete_stock(ctx, **)
          ctx[:error] = 'Current stock import is still running, please import daily updates when its done.'
        end

        def log_incomplete_update(ctx, **)
          ctx[:error] = 'The current update is still running. Abort...'
        end
      end
    end
  end
end
