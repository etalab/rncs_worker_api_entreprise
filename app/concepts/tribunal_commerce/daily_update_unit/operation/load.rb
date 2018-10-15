module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class Load < Trailblazer::Operation
        step :fetch_transmissions
        step :order_transmissions
        step :import


        def fetch_transmissions(ctx, daily_update_unit:, **)
          pattern = ::File.join(daily_update_unit.files_path, '*')
          paths = Dir.glob(pattern)
          ctx[:transmissions_paths] = paths # unless flux_paths.empty?
        end

        def order_transmissions(ctx, transmissions_paths:, **)
          transmissions_paths.sort_by! do |path|
            number = path.split('/').last
            number.to_i
          end
        end

        def import(ctx, transmissions_paths:, **)
          transmissions_paths.each do |transmission_path|
            import = TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission
              .call(files_path: transmission_path)

            return false if import.failure?
          end
        end
      end
    end
  end
end
