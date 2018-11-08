module DataSource
  module File
    module Obs
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step ->(ctx, type_import:, **) { [:stock, :flux].include?(type_import) }
            fail :invalid_type_import, fail_fast: true

          step ->(ctx, type_import:, **) { type_import == :stock }
            fail :line_import, Output(:success) => 'End.success'
          step :mass_import


          def mass_import(ctx, file_path:, file_reader:, **)
            mapping = OBS_HEADER_MAPPING
            file_reader.bulk_processing(file_path, mapping) do |batch|
              Observation.import(batch)
            end
          end

          def line_import(ctx, file_path:, file_reader:, logger:, **)
            file_reader.line_processing(file_path, OBS_HEADER_MAPPING) do |line|
              line_import = Observation::Operation::Create.call(data: line)

              if line_import.failure?
                logger.error(line_import[:error])
                return false
              end
            end
          end

          def invalid_type_import(ctx, logger:, type_import:, **)
            logger.error("Invalid call for file import : import type :#{type_import} is unknown.")
          end
        end
      end
    end
  end
end
