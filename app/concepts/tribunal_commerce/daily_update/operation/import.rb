module TribunalCommerce
  module DailyUpdate
    module Operation
      class Import < Trailblazer::Operation
        step Nested(Task::NextQueuedUpdate), fail_fast: true
        step ->(ctx, daily_update:, **) { daily_update.update(proceeded: true) }

        step :partial_stock?
          step Nested(Task::FetchPartialStocks)
          fail Nested(Task::FetchUnits), Output(:success) => Track(:success)

        step :create_jobs_for_import


        def create_jobs_for_import(ctx, daily_update:, **)
          daily_update.daily_update_units.each do |unit|
            ImportTcDailyUpdateUnitJob.perform_later(unit.id)
          end
        end

        def partial_stock?(ctx, daily_update:, **)
          daily_update.partial_stock?
        end
      end
    end
  end
end
