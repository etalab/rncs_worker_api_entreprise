module TribunalInstance
  module DailyUpdate
    module Unit
      module Operation
        class LoadTransmission < Trailblazer::Operation

          pass :log_import_start
          step Subprocess(Files::Operation::CheckMD5), Output(:fail_fast) => End(:fail_fast)
          step Subprocess(ZIP::Operation::Extract)
            fail :log_zip_error, fail_fast: true
          pass :log_files_unzipped
          step :import

          step ->(ctx, dest_directory:, **) { FileUtils.rm_rf dest_directory }
          fail ->(ctx, dest_directory:, **) { FileUtils.rm_rf dest_directory }

          def import(ctx, extracted_files:, logger:, **)
            extracted_files.each do |path|
              operation = Import.call(path: path, logger: logger)

              return false if operation.failure?
            end
          end

          def log_import_start(ctx, path:, logger:, **)
            logger.info "Starting import of transmission: #{path}"
          end

          def log_zip_error(ctx, logger:, **)
            logger.error ctx[:error]
          end

          def log_files_unzipped(ctx, extracted_files:, logger:, **)
            logger.info "#{extracted_files.count} file(s) extracted"
          end
        end
      end
    end
  end
end
