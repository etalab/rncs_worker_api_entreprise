module TribunalCommerce
  module File
    module EtsNouveauModifie
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :update_or_create


          def update_or_create(ctx, file_reader:, file_path:, logger:, **)
            mapping = ETS_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              update_or_create_ets = Etablissement::Operation::NouveauModifie.call(data: line)

              if update_or_create_ets.failure?
                logger.error(update_or_create_ets[:error])
                return false
              else
                logger.warn(update_or_create_ets[:warning]) unless update_or_create_ets[:warning].nil?
              end
            end
          end
        end
      end
    end
  end
end
