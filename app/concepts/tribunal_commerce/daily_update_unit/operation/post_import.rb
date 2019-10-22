module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class PostImport < Trailblazer::Operation
        step ->(_, daily_update_unit:, **) {
          daily_update = daily_update_unit.daily_update
          daily_update.status == 'COMPLETED'
        }

        step Nested(TribunalCommerce::DailyUpdate::Operation::Import)
      end
    end
  end
end
