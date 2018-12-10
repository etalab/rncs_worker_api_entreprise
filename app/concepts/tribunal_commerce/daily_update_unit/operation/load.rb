module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class Load < Trailblazer::Operation
        step :log_import_start
        step :fetch_transmissions
        step :order_transmissions
        step :import
        step :log_success


        def log_import_start(ctx, logger:, daily_update_unit:, **)
          daily_update_date = daily_update_unit.daily_update.date.to_s
          logger.info("START IMPORT OF UPDATE #{daily_update_date}")
        end

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

        def import(ctx, transmissions_paths:, logger:, **)
          transmissions_paths.each do |transmission_path|
            transmission_number = transmission_path.split('/').last
            logger.info("Starting to import transmission number #{transmission_number}...")
            import = TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission
              .call(files_path: transmission_path, logger: logger)

            if import.success?
              logger.info("Import of transmission number #{transmission_number} is complete !")
            else
              logger.error("An error occured while importing transmission number #{transmission_number}. Aborting daily update unit import...")
              return false
            end
          end
        end

        def log_success(ctx, daily_update_unit:, logger:, **)
          logger.info("Each transmission has been successfuly imported. The daily update is a success for greffe #{daily_update_unit.code_greffe} !")
        end
      end
    end
  end
end
