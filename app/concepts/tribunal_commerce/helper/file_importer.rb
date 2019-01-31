module TribunalCommerce
  module Helper
    class FileImporter
      def initialize(file_reader = DataSource::File::CSVReader)
        @file_reader = file_reader
      end

      def supersede_dossiers_entreprise_from_pm(path)
        mapping = DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING
        @file_reader.line_processing(path, mapping) do |line|
          line_import = DossierEntreprise::Operation::Supersede.call(data: line)

          if line_import.failure?
            logger.error(line_import[:error])
            return false
          else
            logger.warn(line_import[:warning]) unless line_import[:warning].nil?
          end
        end
      end

      def supersede_dossiers_entreprise_from_pp(path)

      end

      def import_personnes_morales(path)

      end

      def import_personnes_physiques(path)

      end

      def import_representants(path)

      end

      def import_etablissements(path)

      end

      def import_observations(path)

      end
    end
  end
end
