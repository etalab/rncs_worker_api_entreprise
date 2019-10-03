module TribunalCommerce
  module DailyUpdate
    module Task
      class NextQueuedUpdate < Trailblazer::Operation
        step :retrieve_last_update
        fail :retrieve_last_stock, Output(:success) => :next_update
        fail :no_stock_imported, fail_fast: true
        step :ensure_last_daily_import_is_completed
        fail :log_last_update_fail, fail_fast: true
        step :retrieve_next_queued_update, id: :next_update
        fail :log_empty_queue

        def retrieve_last_update(ctx, **)
          ctx[:last_update] = DailyUpdateTribunalCommerce.current
        end

        def retrieve_last_stock(_, **)
          last_stock = StockTribunalCommerce.current
          return false if last_stock.nil?

          last_stock.status == 'COMPLETED'
        end

        def ensure_last_daily_import_is_completed(_, last_update:, **)
          last_update.status == 'COMPLETED'
        end

        # TODO: rename context key to next_update
        def retrieve_next_queued_update(ctx, **)
          ctx[:daily_update] = DailyUpdateTribunalCommerce.next_in_queue
        end

        def log_empty_queue(ctx, **)
          ctx[:error] = 'No updates have been queued for import.'
        end

        def log_last_update_fail(ctx, last_update:, **)
          ctx[:error] = "The last update #{last_update.date} is not completed. Aborting import..."
        end

        def no_stock_imported(ctx, **)
          ctx[:error] = 'No stock has been fully imported yet. Aborting...'
        end
      end
    end
  end
end
