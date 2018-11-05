module DataSource
  module File
    module PM
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step ->(ctx, type_import:, **) { [:stock, :flux].include?(type_import) }
            fail :invalid_type_import, fail_fast: true

          step :mass_import_dossiers_entreprise
          step ->(ctx, type_import:, **) { type_import == :stock }
            fail :line_import_personnes_morales, Output(:success) => 'End.success'
          step :mass_import_personnes_morales


          def mass_import_dossiers_entreprise(ctx, file_path:, file_reader:, **)
            mapping = DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING
            file_reader.bulk_processing(file_path, mapping) do |batch|
              DossierEntreprise.import(batch)
            end
          end

          def mass_import_personnes_morales(ctx, file_path:, file_reader:, **)
            mapping = PM_HEADER_MAPPING
            file_reader.bulk_processing(file_path, mapping) do |batch|
              PersonneMorale.import(batch)
            end
          end

          def line_import_personnes_morales(ctx, file_path:, file_reader:, **)
            file_reader.line_processing(file_path, PM_HEADER_MAPPING) do |line|
              line_import = PersonneMorale::Operation::Create.call(data: line)

              return false if line_import.failure?
            end
          end

          def invalid_type_import(ctx, logger:, type_import:, **)
            logger.error("Invalid call for file import : import type :#{type_import} is unknown.")
          end
        end
      end
    end
  end
end
