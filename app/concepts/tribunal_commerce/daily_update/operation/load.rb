module TribunalCommerce
  module DailyUpdate
    module Operation
      class Load < Trailblazer::Operation
        step Nested(DBStateDate)
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

        def no_updates_to_import(ctx, raw_date:, **)
          Rails.logger.info("No daily updates available after `#{raw_date}`. Nothing to import.")
        end
      end
    end
  end
end
