module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class PostImport < Trailblazer::Operation
        step ->(ctx, daily_update_unit:, **) do
          daily_update = daily_update_unit.daily_update
          daily_update.status == 'COMPLETED'
        end

        step Nested(TribunalCommerce::DailyUpdate::Operation::Import)
      end
    end
  end
end
