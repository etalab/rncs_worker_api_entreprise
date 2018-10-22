module TribunalCommerce
  module DailyUpdate
    module Operation
      class Import < Trailblazer::Operation
        step Nested(Task::NextQueuedUpdate)
        step ->(ctx, daily_update:, **) { daily_update.update(proceeded: true) }
        step Nested(Task::FetchUnits)
        step :create_jobs_for_import


        def create_jobs_for_import(ctx, daily_update:, **)
          daily_update.daily_update_units.each do |unit|
            ImportTcDailyUpdateUnitJob.perform_later(unit.id)
          end
        end
      end
    end
  end
end
