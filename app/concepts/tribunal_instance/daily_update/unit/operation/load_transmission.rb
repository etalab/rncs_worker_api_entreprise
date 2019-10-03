module TribunalInstance
  module DailyUpdate
    module Unit
      module Operation
        class LoadTransmission < Trailblazer::Operation
          pass :log_import_start
          step Nested Files::Operation::CheckMD5
          step Nested ZIP::Operation::Extract
          fail :log_zip_error, fail_fast: true
          pass :log_files_unzipped
          step :import

          step ->(_, dest_directory:, **) { FileUtils.rm_rf dest_directory }
          fail ->(_, dest_directory:, **) { FileUtils.rm_rf dest_directory }

          def import(_, extracted_files:, logger:, **)
            extracted_files.each do |path|
              operation = Import.call path: path, logger: logger

              return false if operation.failure?
            end
          end

          def log_import_start(_, path:, logger:, **)
            logger.info "Starting import of transmission: #{path}"
          end

          def log_zip_error(ctx, logger:, **)
            logger.error ctx[:error]
          end

          def log_files_unzipped(_, extracted_files:, logger:, **)
            logger.info "#{extracted_files.count} file(s) extracted"
          end
        end
      end
    end
  end
end
