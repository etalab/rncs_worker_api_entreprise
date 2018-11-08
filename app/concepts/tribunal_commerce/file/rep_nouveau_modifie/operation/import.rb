module TribunalCommerce
  module File
    module RepNouveauModifie
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :update_or_create


          def update_or_create(ctx, file_reader:, file_path:, logger:, **)
            mapping = REP_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              update_or_create_rep = Representant::Operation::NouveauModifie.call(data: line)

              if update_or_create_rep.failure?
                logger.error(update_or_create_rep[:error])
                return false
              end
            end
          end
        end
      end
    end
  end
end
