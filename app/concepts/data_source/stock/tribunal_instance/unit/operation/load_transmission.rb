module DataSource
  module Stock
    module TribunalInstance
      module Unit
        module Operation
          class LoadTransmission < Trailblazer::Operation

            step Nested(ZIP::Operation::Extract)
            fail :log_nested_error, fail_fast: true
            step :check_file_count
            fail :too_many_files, fail_fast: true
            step ->(ctx, extracted_files:, **) { ctx[:extracted_file] = extracted_files.first }
            pass :log_zip_info
            step Nested(Import)
            fail :log_nested_error

            # TODO: find a better solution ?
            step ->(ctx, dest_directory:, **) { FileUtils.rm_rf(dest_directory) }
            fail ->(ctx, dest_directory:, **) { FileUtils.rm_rf(dest_directory) }

            def check_file_count(ctx, extracted_files:, **)
              extracted_files.count == 1
            end

            def too_many_files(ctx, logger:, path:, extracted_files:, **)
              filename = Pathname.new(path).basename
              file_count = extracted_files.count
              logger.error "Zip file #{filename} contains too many files (expected 1 got #{file_count})"
            end

            def log_zip_info(ctx, logger:, extracted_file:, **)
              logger.info "File extracted: #{extracted_file}"
            end

            def log_nested_error(ctx, logger:, **)
              logger.error ctx[:error]
            end
          end
        end
      end
    end
  end
end
