module TribunalCommerce
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation
        extend ClassDependencies

        self[:logger] = Rails.logger

        pass ->(ctx, logger:, **) { logger.info('Fetching new daily updates to import...') }
        step Nested(DBCurrentDate)
        step ->(ctx, logger:, db_current_date:, **) { logger.info("The database is sync until the date #{db_current_date}.") }
        step Nested(FetchInPipe)
        step :ignores_older_updates
        fail :no_updates_to_import
        step :save_handled_updates


        def ignores_older_updates(ctx, daily_updates:, db_current_date:, **)
          daily_updates.keep_if { |update| update.newer?(db_current_date) }
          !daily_updates.empty?
        end

        def save_handled_updates(ctx, daily_updates:, **)
          daily_updates.each { |e| e.proceeded = false }
          daily_updates.each(&:save)
        end

        def no_updates_to_import(ctx, db_current_date:, logger:, **)
          logger.info("No daily updates available after `#{db_current_date}`. Nothing to import.")
        end
      end
    end
  end
end
