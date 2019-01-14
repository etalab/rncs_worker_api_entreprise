module DataSource
  module Stock
    module TribunalInstance
      module Unit
        module Operation
          class Load < Trailblazer::Operation

            pass :log_info_stock
            step :fetch_transmissions
            pass :log_info_stock_unit_files
            step ->(ctx, stock_unit:, **) { ctx[:code_greffe] = stock_unit.code_greffe }
            #step ResetDatabase # TODO when TITMC model is designed
            fail :log_reset_database_failure
            step :load_greffe_files
            fail :log_transmission_failure

            def log_info_stock(ctx, logger:, stock_unit:, **)
              logger.info "Starting import of stock #{stock_unit.stock.date}"
            end

            def fetch_transmissions(ctx, stock_unit:, **)
              ctx[:transmissions] = Dir.glob(stock_unit.file_path).sort
            end

            def log_info_stock_unit_files(ctx, logger:, stock_unit:, transmissions:, **)
              filenames = transmissions.map { |path|
                Pathname.new(path).basename
              }.join(', ')

              logger.info "Stock unit for Greffe:#{stock_unit.code_greffe} (#{filenames})"
            end

            def log_reset_database_failure(ctx, logger:, **)
              logger.error ctx[:error]
            end

            def load_greffe_files(ctx, transmissions:, code_greffe:, logger:, **)
              transmissions.each do |transmission_path|
                operation = LoadTransmission.call(
                  code_greffe: code_greffe,
                  path: transmission_path,
                  logger: logger
                )

                if operation.failure?
                  ctx[:failed_transmission] = operation
                  return false
                end
              end
            end

            def log_transmission_failure(ctx, logger:, failed_transmission:, **)
              logger.error "Transmission failed (file: #{failed_transmission[:path]}, error: #{failed_transmission[:error]})"
            end
          end
        end
      end
    end
  end
end
