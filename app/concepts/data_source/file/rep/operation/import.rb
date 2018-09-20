module DataSource
  module File
    module Rep
      module Operation
        class Import < Trailblazer::Operation
          step ->(ctx, file_path:, **) do
            csv_reader = File::CSVReader.new(
              file_path,
              REP_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              Representant.import batch, validate: false
            end
          end
        end
      end
    end
  end
end
