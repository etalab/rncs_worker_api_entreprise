module DataSource
  module File
    module PP
      module Operation
        class Import < Trailblazer::Operation
          step :import_dossiers_entreprise
          step :import_personnes_physique


          def import_dossiers_entreprise(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              DossierEntreprise.import batch, validate: false
            end
          end

          def import_personnes_physique(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              PP_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              PersonnePhysique.import batch, validate: false
            end
          end
        end
      end
    end
  end
end
