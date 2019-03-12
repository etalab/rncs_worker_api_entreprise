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
        step Nested(FetchPartialStocksInPipe)
        step :append_partial_stocks_to_daily_updates
        step :ignores_older_updates
        step :limit_update_to_keep
        step :delay_update
          fail :no_updates_to_import
        step :save_handled_updates


        def append_partial_stocks_to_daily_updates(ctx, partial_stocks:, **)
          ctx[:daily_updates].push(*partial_stocks)
        end

        def ignores_older_updates(ctx, daily_updates:, db_current_date:, **)
          daily_updates.keep_if { |update| update.newer?(db_current_date) }
        end

        def limit_update_to_keep(ctx, daily_updates:, limit:nil, db_current_date:, **)
          unless limit.nil?
            date_limit = db_current_date + limit
            daily_updates.keep_if { |update| update.older?(date_limit) }
          end

          ctx[:daily_updates].any?
        end

        def delay_update(ctx, daily_updates:, delay:nil, **)
          unless delay.nil?
            date_limit = Date.today - delay
            daily_updates.keep_if { |update| update.older?(date_limit) }
          end

          ctx[:daily_updates].any?
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
