module TribunalCommerce
  module File
    module PMEvent
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step :update_dossiers_entreprise
          step :update_personnes_morales


          def update_dossiers_entreprise(ctx, file_reader:, file_path:, **)
            mapping = DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING
            file_reader.line_processing(file_path, mapping) do |line|
              dossier_update = DossierEntreprise::Operation::Update.call(data: line)

              return false if dossier_update.failure?
            end
          end

          def update_personnes_morales(ctx, file_reader:, file_path:, **)
            file_reader.line_processing(file_path, PM_HEADER_MAPPING) do |line|
              personne_morale_update = PersonneMorale::Operation::Update.call(data: line)

              return false if personne_morale_update.failure?
            end
          end
        end
      end
    end
  end
end
