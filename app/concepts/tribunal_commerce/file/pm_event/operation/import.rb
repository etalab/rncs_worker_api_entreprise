module TribunalCommerce
  module File
    module PMEvent
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :update_dossiers_entreprise
          step :update_personnes_morales


          def update_dossiers_entreprise(ctx, file_reader:, file_path:, logger:, **)
            mapping = DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              dossier_update = DossierEntreprise::Operation::Update.call(data: line)

              if dossier_update.failure?
                logger.error(dossier_update[:error])
                return false
              end
            end
          end

          def update_personnes_morales(ctx, file_reader:, file_path:, logger:, **)
            file_reader.line_processing(file_path, PM_HEADER_MAPPING) do |line|
              pm_update = PersonneMorale::Operation::Update.call(data: line)

              if pm_update.failure?
                logger.error(pm_update[:error])
                return false
              end
            end
          end
        end
      end
    end
  end
end
