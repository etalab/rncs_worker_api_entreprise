module TribunalCommerce
  module DailyUpdate
    module Operation
      class DBCurrentDate < Trailblazer::Operation
        step :queued_updates?
        fail :log_updates_waiting_for_import, fail_fast: true
        step :latest_daily_update_imported, Output(:failure) => Track(:no_daily_updates_yet)
        step :daily_update_completed?
        fail :log_incomplete_update, fail_fast: true
        step :raw_daily_update_date

        step :current_stock, magnetic_to: [:no_daily_updates_yet], Output(:success) => Track(:no_daily_updates_yet)
        fail :log_empty_db, fail_fast: true
        step :stock_completed?, magnetic_to: [:no_daily_updates_yet], Output(:success) => Track(:no_daily_updates_yet)
        fail :log_incomplete_stock, fail_fast: true
        step :raw_stock_date, magnetic_to: [:no_daily_updates_yet], Output(:success) => 'End.success'

        def queued_updates?(ctx, **)
          !DailyUpdateTribunalCommerce.queued_updates?
        end

        def latest_daily_update_imported(ctx, **)
          ctx[:current_daily_update] = DailyUpdateTribunalCommerce.current
        end

        def daily_update_completed?(ctx, current_daily_update:, **)
          current_daily_update.status == 'COMPLETED'
        end

        def raw_daily_update_date(ctx, current_daily_update:, **)
          ctx[:db_current_date] = current_daily_update.date
        end

        def current_stock(ctx, **)
          ctx[:current_stock] = StockTribunalCommerce.current
        end

        def stock_completed?(ctx, current_stock:, **)
          current_stock.status == 'COMPLETED'
        end

        def raw_stock_date(ctx, current_stock:, **)
          ctx[:db_current_date] = current_stock.date
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

        def log_updates_waiting_for_import(ctx, **)
          ctx[:error] = 'Pending daily updates found in database. Aborting... Please import remaining updates first.'
        end
      end
    end
  end
end
