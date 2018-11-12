module TribunalCommerce
  module File
    module PPEvent
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :update_dossiers_entreprise
          step :update_personnes_physiques


          def update_dossiers_entreprise(ctx, file_reader:, file_path:, logger:, **)
            mapping = DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              dossier_update = DossierEntreprise::Operation::Update.call(data: line)

              if dossier_update.failure?
                logger.error(dossier_update[:error])
                return false
              end
            end
          end

          def update_personnes_physiques(ctx, file_reader:, file_path:, logger:, **)
            file_reader.line_processing(file_path, PP_HEADER_MAPPING) do |line|
              pp_update = PersonnePhysique::Operation::Update.call(data: line)

              if pp_update.failure?
                logger.error(pp_update[:error])
                return false
              end
            end
          end
        end
      end
    end
  end
end
