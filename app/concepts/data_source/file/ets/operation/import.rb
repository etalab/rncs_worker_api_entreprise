module DataSource
  module File
    module Ets
      module Operation
        class Import < Trailblazer::Operation
          step ->(ctx, file_path:, **) do
            csv_reader = File::CSVReader.new(
              file_path,
              ETS_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              Etablissement.import batch, validate: false
            end
          end
        end
      end
    end
  end
end
