module TribunalInstance
  module DailyUpdate
    module Task
      class FetchUnits < Trailblazer::Operation

        step :fetch_daily_updates_units
          fail :log_empty_folder, fail_fast: true
        step :deserialize
          fail :log_wrong_directory_name

        def fetch_daily_updates_units(ctx, daily_update:, **)
          ctx[:units_path] = Dir.glob(daily_update.files_path + '/*')
          ctx[:units_path].any?
        end

        def deserialize(ctx, daily_update:, units_path:, **)
          daily_update_units = units_path.map do |unit_path|
            if unit_path.match(/\A#{daily_update.files_path}\/.{12}_\d{14}TITMCFLUX\Z/)
              daily_update.daily_update_units.create(
                code_greffe: 'UNKNOWN',
                status: 'PENDING',
                files_path: unit_path,
              )
            else
              return false
            end
          end

          ctx[:daily_update_units] = daily_update_units
        end

        def log_empty_folder(ctx, daily_update:, logger:, **)
          logger.error "No directory found in daily update #{daily_update.files_path}"
        end

        def log_wrong_directory_name(ctx, daily_update:, logger:, **)
          logger.error "Unexpected directory name in daily update #{daily_update.files_path}"
        end
      end
    end
  end
end
