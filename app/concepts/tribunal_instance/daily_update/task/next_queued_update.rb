module TribunalInstance
  module DailyUpdate
    module Task
      class NextQueuedUpdate < Trailblazer::Operation

        step :retrieve_last_update, Output(:failure) => Track(:no_previous_update)
        step :ensure_last_daily_import_is_completed
          fail :log_last_update_fail, fail_fast: true

        step :retrieve_next_queued_update, magnetic_to: [:success, :no_previous_update]
          fail :log_empty_queue

        def retrieve_last_update(ctx, **)
          ctx[:last_update] = DailyUpdateTribunalInstance.current
        end

        def ensure_last_daily_import_is_completed(ctx, last_update:, **)
          last_update.status == 'COMPLETED'
        end

        def retrieve_next_queued_update(ctx, **)
          ctx[:daily_update] = DailyUpdateTribunalInstance.next_in_queue
        end

        def log_empty_queue(ctx, logger:, **)
          logger.error 'No updates have been queued for import.'
        end

        def log_last_update_fail(ctx, logger:, last_update:, **)
          logger.error "The last update #{last_update.date} is not completed. Aborting import..."
        end
      end
    end
  end
end
