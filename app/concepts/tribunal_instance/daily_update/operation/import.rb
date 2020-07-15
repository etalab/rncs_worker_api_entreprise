module TribunalInstance
  module DailyUpdate
    module Operation
      class Import < Trailblazer::Operation

        step Subprocess(Task::NextQueuedUpdate)
        step ->(ctx, daily_update:, **) { daily_update.update(proceeded: true) }
        step Subprocess(Task::FetchUnits), Output(:fail_fast) => End(:fail_fast)
        step :create_jobs_for_import

        def create_jobs_for_import(ctx, daily_update:, **)
          daily_update.daily_update_units.each do |unit|
            ImportTitmcDailyUpdateUnitJob.perform_later(unit.id)
          end
        end
      end
    end
  end
end
