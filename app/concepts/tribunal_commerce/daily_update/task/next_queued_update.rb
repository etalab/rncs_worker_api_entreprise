module TribunalCommerce
  module DailyUpdate
    module Task
      class NextQueuedUpdate < Trailblazer::Operation
        step :ensure_last_daily_import_is_completed
          fail :log_last_update_fail, fail_fast: true
        step :retrieve_next_queued_update
          fail :log_empty_queue


        def ensure_last_daily_import_is_completed(ctx, **)
          last_update = DailyUpdateTribunalCommerce.current
          last_update.status == 'COMPLETED'
        end

        def retrieve_next_queued_update(ctx, **)
          ctx[:daily_update] = DailyUpdateTribunalCommerce.next_in_queue
        end

        def log_empty_queue(ctx, **)
          current = DailyUpdateTribunalCommerce.current
          ctx[:error] = "No queued update after #{current.date}."
        end

        def log_last_update_fail(ctx, **)
          current = DailyUpdateTribunalCommerce.current
          ctx[:error] = "The last update #{current.date} is not completed. Aborting import..."
        end
      end
    end
  end
end
