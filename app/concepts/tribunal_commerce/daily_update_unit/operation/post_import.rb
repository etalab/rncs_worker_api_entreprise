module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class PostImport < Trailblazer::Operation
        step ->(ctx, daily_update_unit:, **) do
          daily_update = daily_update_unit.daily_update
          daily_update.status == 'COMPLETED'
        end

        step Subprocess(TribunalCommerce::DailyUpdate::Operation::Import), Output(:fail_fast) => End(:fail_fast)
      end
    end
  end
end
