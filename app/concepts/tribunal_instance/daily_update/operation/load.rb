module TribunalInstance
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation

        step ->(ctx, logger:, **) { logger.info 'Fetching new daily updates' }
        step Subprocess(Task::DBCurrentDate), Output(:fail_fast) => End(:fail_fast)
        pass :log_sync_status
        step Subprocess(Task::FetchInPipe)
        step :set_default_db_current_date
        step :ignores_older_updates
        step :limit_update_to_keep
        fail :log_no_updates_to_import
        pass :log_how_many_updates_found
        step :save_handled_updates
        step Subprocess(Import), Output(:fail_fast) => End(:fail_fast)

        def set_default_db_current_date(ctx, daily_updates:, **)
          unless ctx.key?(:db_current_date)
            oldest_daily_update = daily_updates.sort_by(&:date).first
            day_before_first_update = oldest_daily_update.date - 1
            ctx[:db_current_date] = day_before_first_update
          else
            true
          end
        end

        def ignores_older_updates(ctx, daily_updates:, db_current_date:, **)
          daily_updates.keep_if { |update| update.newer?(db_current_date) }
        end

        def limit_update_to_keep(ctx, daily_updates:, **)
          if import_option_provided? ctx
            daily_updates.keep_if { |update| !update.newer?(date_limit_to_import ctx) }
          end

          ctx[:daily_updates].any?
        end

        def save_handled_updates(ctx, daily_updates:, **)
          daily_updates.each do |e|
            e.proceeded = false
            e.save
          end
        end

        def log_sync_status(ctx, logger:, **)
          if ctx.key?(:db_current_date)
            logger.info "The database is sync until #{ctx[:db_current_date]}."
          else
            logger.info 'First run, no daily updates'
          end
        end

        def log_no_updates_to_import(ctx, db_current_date:, logger:, **)
          logger.info "No daily updates available after #{db_current_date}. Nothing to import."
        end

        def log_how_many_updates_found(ctx, daily_updates:, logger:, **)
          logger.info "#{daily_updates.count} daily updates found."
        end

        private

        def import_option_provided?(ctx)
          !ctx[:import_until_date].nil? || !ctx[:import_next_x_days].nil?
        end

        def date_limit_to_import(ctx)
          until_date_to_import = ctx[:db_current_date] + ctx[:import_next_x_days] if ctx[:import_next_x_days]
          until_date_to_import = ctx[:import_until_date].to_date                  if ctx[:import_until_date]

          return until_date_to_import
        end
      end
    end
  end
end
