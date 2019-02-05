module TribunalCommerce
  module Helper
    class FileImporter
      attr_reader :file_reader, :logger

      # TODO here container would be great because it could provide the right logger
      # logger should not default to nil.
      def initialize(file_reader = DataSource::File::CSVReader, logger = nil)
        @file_reader = file_reader
        @logger = logger
      end

      # Following methods knows how to process the files:
      #  - line by line or bulk import
      #  - which header map to use to read each CSV files
      #  - the operation that handles each line raw data
      def supersede_dossiers_entreprise_from_pm(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING, DossierEntreprise::Operation::Supersede)
      end

      def supersede_dossiers_entreprise_from_pp(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING, DossierEntreprise::Operation::Supersede)
      end

      def import_personnes_morales(path)
        import_line_by_line(path, PM_HEADER_MAPPING, PersonneMorale::Operation::Create)
      end

      def import_personnes_physiques(path)
        import_line_by_line(path, PP_HEADER_MAPPING, PersonnePhysique::Operation::Create)
      end

      def import_representants(path)
        import_line_by_line(path, REP_HEADER_MAPPING, Representant::Operation::Create)
      end

      def import_etablissements(path)
        import_line_by_line(path, ETS_HEADER_MAPPING, Etablissement::Operation::Create)
      end

      def import_observations(path)
        import_line_by_line(path, OBS_HEADER_MAPPING, Observation::Operation::UpdateOrCreate)
      end

      private

      def import_line_by_line(file_path, file_header_mapping, line_processor)
        file_reader.line_processing(file_path, file_header_mapping) do |line|
          line_import = line_processor.call(data: line)

          if line_import.failure?
            logger.error(line_import[:error])
            return false
          else
            logger.warn(line_import[:warning]) unless line_import[:warning].nil?
          end
        end
      end
    end
  end
end
