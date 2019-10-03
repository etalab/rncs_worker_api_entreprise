module TribunalInstance
  module DailyUpdate
    module Unit
      module Operation
        class Load < Trailblazer::Operation
          pass :log_import_start
          step :fetch_transmissions
          fail :log_no_transmission_found, fail_fast: true
          pass :log_transmissions_count
          step :load_transmissions
          pass :log_success

          def fetch_transmissions(ctx, daily_update_unit:, **)
            ctx[:transmissions] = Dir.glob daily_update_unit.files_path + '/*.zip'
            ctx[:transmissions].any?
          end

          def load_transmissions(_, transmissions:, logger:, **)
            transmissions.each do |path|
              operation = LoadTransmission.call(
                path: path,
                logger: logger
              )

              return false if operation.failure?
            end
          end

          def log_import_start(_, daily_update_unit:, logger:, **)
            logger.info "Starting import of #{daily_update_unit.files_path}"
          end

          def log_transmissions_count(_, transmissions:, logger:, **)
            logger.info "#{transmissions.count} files founds"
          end

          def log_no_transmission_found(_, daily_update_unit:, logger:, **)
            logger.error "No transmission found in #{daily_update_unit.files_path}"
          end

          def log_success(_, logger:, **)
            logger.info 'All transmissions imported successfully'
          end
        end
      end
    end
  end
end
