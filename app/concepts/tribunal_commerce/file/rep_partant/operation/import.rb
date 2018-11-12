module TribunalCommerce
  module File
    module RepPartant
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :delete_representant_partant


          def delete_representant_partant(ctx, file_reader:, file_path:, logger:, **)
            mapping = REP_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              delete_rep = Representant::Operation::Delete.call(data: line)

              if delete_rep.failure?
                logger.error(delete_rep[:error])
                return false
              end
            end
          end

        end
      end
    end
  end
end
