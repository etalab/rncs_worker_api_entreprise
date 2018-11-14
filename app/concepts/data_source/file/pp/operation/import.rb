module DataSource
  module File
    module PP
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          self[:file_reader] = DataSource::File::CSVReader

          step ->(ctx, type_import:, **) { [:stock, :flux].include?(type_import) }
            fail :log_invalid_import, fail_fast: true

          step :mass_import_dossiers_entreprise
          step ->(ctx, type_import:, **) { type_import == :stock }
            fail :line_import_personnes_physiques, Output(:success) => 'End.success'
          step :mass_import_personnes_physiques


          def mass_import_dossiers_entreprise(ctx, file_path:, file_reader:, **)
            mapping = DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING
            file_reader.bulk_processing(file_path, mapping) do |batch|
              DossierEntreprise.import(batch)
            end
          end

          def mass_import_personnes_physiques(ctx, file_path:, file_reader:, **)
            mapping = PP_HEADER_MAPPING
            file_reader.bulk_processing(file_path, mapping) do |batch|
              PersonnePhysique.import(batch)
            end
          end

          def line_import_personnes_physiques(ctx, file_path:, file_reader:, logger:, **)
            file_reader.line_processing(file_path, PP_HEADER_MAPPING) do |line|
              line_import = PersonnePhysique::Operation::Create.call(data: line)

              if line_import.failure?
                logger.error(line_import[:error])
                return false
              else
                logger.warn(line_import[:warning]) unless line_import[:warning].nil?
              end
            end
          end

          def log_invalid_import(ctx, logger:, type_import:, **)
            logger.error("Invalid call for file import : import type :#{type_import} is unknown.")
          end
        end
      end
    end
  end
end
