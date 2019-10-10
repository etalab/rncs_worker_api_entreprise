module TribunalInstance
  module DailyUpdate
    module Task
      class DBCurrentDate < Trailblazer::Operation
        step :queued_updates?
        fail :log_updates_waiting_for_import, fail_fast: true

        step :latest_daily_update_imported, Output(:failure) => Track(:empty_database)
        step :daily_update_completed?
        fail :log_incomplete_update, fail_fast: true

        step :raw_daily_update_date, Output(:failure) => Track(:empty_database)

        pass :log_no_daily_update, magnetic_to: [:empty_database]

        def queued_updates?(_, **)
          !DailyUpdateTribunalInstance.queued_updates?
        end

        def latest_daily_update_imported(ctx, **)
          ctx[:current_daily_update] = DailyUpdateTribunalInstance.current
        end

        def daily_update_completed?(_, current_daily_update:, **)
          current_daily_update.status == 'COMPLETED'
        end

        def raw_daily_update_date(ctx, current_daily_update:, **)
          ctx[:db_current_date] = current_daily_update.date
        end

        def log_incomplete_update(_, logger:, **)
          logger.error('The current update is still running. Aborting...')
        end

        def log_updates_waiting_for_import(_, logger:, **)
          logger.error('Pending daily updates found in database. Aborting...')
        end

        def log_no_daily_update(_, logger:, **)
          logger.info('No existing daily update found, proceeding...')
        end
      end
    end
  end
end
