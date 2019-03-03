module TribunalInstance
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation

        pass ->(ctx, logger:, **) { logger.info 'Fetching new daily updates' }
        step Nested DBCurrentDate
        step ->(ctx, logger:, db_current_date:, **) { logger.info "The database is sync until #{db_current_date}." }
        step Nested FetchInPipe
        step :ignores_older_updates
        step :limit_update_to_keep
        fail :log_no_updates_to_import
        pass :log_how_many_updates_found
        step :save_handled_updates
        step Import

        def ignores_older_updates(ctx, daily_updates:, db_current_date:, **)
          daily_updates.keep_if { |update| update.newer?(db_current_date) }
        end

        def limit_update_to_keep(ctx, daily_updates:, limit: nil, db_current_date:, **)
          unless limit.nil?
            date_limit = db_current_date + limit
            daily_updates.keep_if { |update| !update.newer?(date_limit) }
          end

          ctx[:daily_updates].any?
        end

        def save_handled_updates(ctx, daily_updates:, **)
          daily_updates.each do |e|
            e.proceeded = false
            e.save
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
