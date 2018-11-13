module TribunalCommerce
  module File
    module EtsSupprime
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :delete


          def delete(ctx, file_reader:, file_path:, logger:, **)
            mapping = ETS_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              delete_ets = Etablissement::Operation::Delete.call(data: line)

              if delete_ets.failure?
                logger.error(delete_ets[:error])
                return false
              end
            end
          end
        end
      end
    end
  end
end
