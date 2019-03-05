module TribunalInstance
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation

        pass ->(ctx, logger:, **) { logger.info 'Fetching new daily updates' }
        step Nested Task::DBCurrentDate
        pass :log_sync_status
        step Nested Task::FetchInPipe
        step :set_default_db_current_date
        step :ignores_older_updates
        step :limit_update_to_keep
        fail :log_no_updates_to_import
        pass :log_how_many_updates_found
        step :save_handled_updates
        step Import

        def set_default_db_current_date(ctx, daily_updates:, **)
          unless ctx.key?(:db_current_date)
            oldest_daily_update = daily_updates.sort_by(&:date).first
            ctx[:db_current_date] = oldest_daily_update.date - 1
          else
            true
          end
        end

        def ignores_older_updates(ctx, daily_updates:, db_current_date:, **)
          daily_updates.keep_if { |update| update.newer?(db_current_date) }
        end

        def limit_update_to_keep(ctx, daily_updates:, limit_date: nil, db_current_date:, **)
          unless limit_date.nil?
            limit_date = Date.new *limit_date.split('/').map(&:to_i)
            daily_updates.keep_if { |update| !update.newer?(limit_date) }
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
      end
    end
  end
end
