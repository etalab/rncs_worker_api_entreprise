module TribunalInstance
  module Stock
    module Unit
      module Operation
        class LoadTransmission < Trailblazer::Operation

          pass :log_import_starts
          step Nested(Files::Operation::CheckMD5)
          step Nested(ZIP::Operation::Extract)
          fail :log_zip_error, fail_fast: true
          pass :log_zip_info
          step :import
          fail :log_import_error

          # TODO: find a better solution ?
          step ->(ctx, dest_directory:, **) { FileUtils.rm_rf(dest_directory) }
          fail ->(ctx, dest_directory:, **) { FileUtils.rm_rf(dest_directory) }

          def log_import_starts(ctx, path:, logger:, **)
            logger.info "Starting import of transmission: #{path}"
          end

          def log_zip_error(ctx, logger:, **)
            logger.error ctx[:error]
          end

          def log_zip_info(ctx, logger:, extracted_files:, **)
            logger.info "Files extracted: #{extracted_files}"
          end

          def import(ctx, extracted_files:, code_greffe:, logger:, **)
            extracted_files.each do |extracted_file_path|
              operation = Import.call(
                code_greffe: code_greffe,
                path: extracted_file_path,
                logger: logger
              )

              if operation.success?
                logger.info "Import of tramission #{extracted_file_path} is a success"
              else
                ctx[:failed_operation] = operation
                return false
              end
            end
          end

          def log_import_error(ctx, failed_operation:, path:, logger:, **)
            logger.error "File (#{failed_operation[:path]} from zip #{path}) import failed error: #{failed_operation[:error]}"
          end
        end
      end
    end
  end
end
