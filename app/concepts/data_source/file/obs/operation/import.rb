module DataSource
  module File
    module Obs
      module Operation
        class Import < Trailblazer::Operation
          step ->(ctx, file_path:, **) do
            csv_reader = File::CSVReader.new(
              file_path,
              OBS_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              Observation.import batch, validate: false
            end
          end
        end
      end
    end
  end
end
