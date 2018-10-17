module TrailblazerHelper
  module RSpec
    def trb_result_success
      trb_result(success: true)
    end

    def trb_result_failure
      trb_result(success: false)
    end

    private

    def trb_result(success:, **)
      instance_double(
        Trailblazer::Operation::Railway::Result,
        success?: success,
        failure?: !success
      )
    end
  end
end
