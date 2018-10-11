module TribunalCommerce
  module DailyUpdate
    module Task
      class FetchUnits < Trailblazer::Operation
        step :fetch_daily_updates_units
        step :deserialize


        def fetch_daily_updates_units(ctx, daily_update:, **)
          ctx[:units_path] = Dir.glob(daily_update.files_path + '/*')
        end

        # Daily update units are named by the corresponding code_greffe
        # ex : /daily/update/path/0101
        def deserialize(ctx, daily_update:, units_path:, **)
          daily_update_units = units_path.map do |unit_path|
            if match = unit_path.match(/\A#{daily_update.files_path}\/(\d{4})\Z/)
              code_greffe = match.captures.first

              daily_update.daily_update_units.create(
                code_greffe: code_greffe,
                status: 'PENDING',
                files_path: unit_path,
              )
            end
          end
          # TODO no point to share units within the context object :
          # the associated daily update is already shared
          ctx[:daily_update_units] = daily_update_units
        end
      end
    end
  end
end
