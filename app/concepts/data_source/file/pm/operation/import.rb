module DataSource
  module File
    module PM
      module Operation
        class Import < Trailblazer::Operation
          step ->(ctx, type_import:, **) { [:stock, :flux].include?(type_import) }
            fail :invalid_type_import, fail_fast: true

          step :mass_import_dossiers_entreprise
          step ->(ctx, type_import:, **) { type_import == :stock }
            fail :line_import_personnes_morale, Output(:success) => 'End.success'

          step :mass_import_personnes_morale


          def mass_import_dossiers_entreprise(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              DossierEntreprise.import batch, validate: false
            end
          end

          def mass_import_personnes_morale(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              PM_HEADER_MAPPING)

            csv_reader.proceed do |batch|
              PersonneMorale.import batch, validate: false
            end
          end

          def line_import_personnes_morale(ctx, file_path:, **)
            csv_reader = File::CSVReader.new(
              file_path,
              PM_HEADER_MAPPING,
              filter_nil_values: true
            )

            csv_reader.proceed do |lines|
              lines.each do |line|
                import_line = Operation::AddPersonneMorale.call(data: line)

                return false if import_line.failure?
              end
            end
          end

          def invalid_type_import(ctx, type_import:, **)
            ctx[:error] = "Invalid import type :#{type_import}"
          end
        end
      end
    end
  end
end
