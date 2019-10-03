module TribunalInstance
  module DailyUpdate
    module Operation
      class Import < Trailblazer::Operation
        step Nested Task::NextQueuedUpdate
        step ->(_, daily_update:, **) { daily_update.update(proceeded: true) }
        step Nested Task::FetchUnits
        step :create_jobs_for_import

        def create_jobs_for_import(_, daily_update:, **)
          daily_update.daily_update_units.each do |unit|
            ImportTitmcDailyUpdateUnitJob.perform_later(unit.id)
          end
        end
      end
    end
  end
end
