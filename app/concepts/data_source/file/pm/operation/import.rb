module DataSource
  module File
    module PM
      module Operation
        class Import < Trailblazer::Operation
          step :import_dossiers_entreprise
          step :import_personnes_morale


          def import_dossiers_entreprise(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              DossierEntreprise.import batch, validate: false
            end
          end

          def import_personnes_morale(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              PM_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              PersonneMorale.import batch, validate: false
            end
          end
        end
      end
    end
  end
end
