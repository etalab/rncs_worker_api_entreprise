module TribunalCommerce
  module DaylyUpdate
    module Operation
      class DBStateDate < Trailblazer::Operation
        step :current_dayly_update, Output(:failure) => Track(:no_dayly_updates)
        step :dayly_update_completed?
        fail :log_incomplete_update, fail_fast: true
        step :raw_dayly_update_date

        step :current_stock, magnetic_to: [:no_dayly_updates], Output(:success) => Track(:no_dayly_updates)
        fail :log_empty_db, fail_fast: true
        step :stock_completed?, magnetic_to: [:no_dayly_updates], Output(:success) => Track(:no_dayly_updates)
        fail :log_incomplete_stock, fail_fast: true
        step :raw_stock_date, magnetic_to: [:no_dayly_updates], Output(:success) => 'End.success'


        def current_dayly_update(ctx, **)
          ctx[:current_dayly_update] = DaylyUpdateTribunalCommerce.current
        end

        def dayly_update_completed?(ctx, current_dayly_update:, **)
          current_dayly_update.status == 'COMPLETED'
        end

        def raw_dayly_update_date(ctx, current_dayly_update:, **)
          ctx[:raw_date] = current_dayly_update.date
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
          ctx[:error] = 'Current stock import is still running, please import dayly updates when its done.'
        end

        def log_incomplete_update(ctx, **)
          ctx[:error] = 'The current update is still running. Abort...'
        end
      end
    end
  end
end
