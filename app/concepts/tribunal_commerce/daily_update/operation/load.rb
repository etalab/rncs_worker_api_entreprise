module TribunalCommerce
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation
        extend ClassDependencies

        self[:logger] = Rails.logger

        pass ->(ctx, logger:, **) { logger.info('Fetching new daily updates to import...') }
        step Nested(DBStateDate)
        step ->(ctx, logger:, raw_date:, **) { logger.info("The database is sync until the date #{raw_date}.") }
        step Nested(FetchInPipe)
        step :ignores_older_updates
        fail :no_updates_to_import
        step :save_handled_updates


        def ignores_older_updates(ctx, daily_updates:, raw_date:, **)
          daily_updates.keep_if { |update| update.newer?(raw_date) }
          !daily_updates.empty?
        end

        def save_handled_updates(ctx, daily_updates:, **)
          daily_updates.each { |e| e.proceeded = false }
          daily_updates.each(&:save)
        end

        def no_updates_to_import(ctx, raw_date:, logger:, **)
          logger.info("No daily updates available after `#{raw_date}`. Nothing to import.")
        end
      end
    end
  end
end
