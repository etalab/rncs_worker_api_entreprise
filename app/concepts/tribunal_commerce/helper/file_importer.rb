# rubocop:disable Metrics/ClassLength
module TribunalCommerce
  module Helper
    class FileImporter
      attr_reader :file_reader_class, :logger

      # TODO: here container would be great because it could provide the right logger
      def initialize(logger, file_reader_class = CSVReader)
        @file_reader_class = file_reader_class
        @logger = logger
      end

      # Following methods knows how to process the files:
      #  - line by line or bulk import
      #  - which header map to use to read each CSV files
      #  - the operation that handles each line raw data
      def supersede_dossiers_entreprise_from_pm(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING, DossierEntreprise::Operation::Supersede)
      end

      def import_dossiers_entreprise_evt_from_pm(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING, DossierEntreprise::Operation::Update)
      end

      def import_dossiers_entreprise_from_pm(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING, DossierEntreprise::Operation::Create)
      end

      def import_dossiers_entreprise_evt_from_pp(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING, DossierEntreprise::Operation::Update)
      end

      def supersede_dossiers_entreprise_from_pp(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING, DossierEntreprise::Operation::Supersede)
      end

      def import_dossiers_entreprise_from_pp(path)
        import_line_by_line(path, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING, DossierEntreprise::Operation::Create)
      end

      def import_personnes_morales(path)
        import_line_by_line(path, PM_HEADER_MAPPING, PersonneMorale::Operation::Create)
      end

      def import_personnes_morales_evt(path)
        import_line_by_line(path, PM_HEADER_MAPPING, PersonneMorale::Operation::Update)
      end

      def import_personnes_physiques(path)
        import_line_by_line(path, PP_HEADER_MAPPING, PersonnePhysique::Operation::Create)
      end

      def import_personnes_physiques_evt(path)
        import_line_by_line(path, PP_HEADER_MAPPING, PersonnePhysique::Operation::Update)
      end

      def import_representants(path)
        import_line_by_line(path, REP_HEADER_MAPPING, Representant::Operation::Create)
      end

      def import_representants_nouveau_modifie(path)
        import_line_by_line(path, REP_HEADER_MAPPING, Representant::Operation::NouveauModifie)
      end

      def import_representants_partant(path)
        import_line_by_line(path, REP_HEADER_MAPPING, Representant::Operation::Delete)
      end

      def import_etablissements(path)
        import_line_by_line(path, ETS_HEADER_MAPPING, Etablissement::Operation::Create)
      end

      def import_etablissements_nouveau_modifie(path)
        import_line_by_line(path, ETS_HEADER_MAPPING, Etablissement::Operation::NouveauModifie)
      end

      def import_etablissements_supprime(path)
        import_line_by_line(path, ETS_HEADER_MAPPING, Etablissement::Operation::Delete)
      end

      def import_observations(path)
        import_line_by_line(path, OBS_HEADER_MAPPING, Observation::Operation::UpdateOrCreate)
      end

      def bulk_import_dossiers_entreprise_from_pm(path)
        bulk_import(path, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING, DossierEntreprise)
      end

      def bulk_import_dossiers_entreprise_from_pp(path)
        bulk_import(path, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING, DossierEntreprise)
      end

      def bulk_import_personnes_morales(path)
        bulk_import(path, PM_HEADER_MAPPING, PersonneMorale)
      end

      def bulk_import_personnes_physiques(path)
        bulk_import(path, PP_HEADER_MAPPING, PersonnePhysique)
      end

      def bulk_import_representants(path)
        bulk_import(path, REP_HEADER_MAPPING, Representant)
      end

      def bulk_import_etablissements(path)
        bulk_import(path, ETS_HEADER_MAPPING, Etablissement)
      end

      def bulk_import_observations(path)
        bulk_import(path, OBS_HEADER_MAPPING, Observation)
      end

      private

      def import_line_by_line(file_path, file_header_mapping, line_processor)
        logger.info("Starting import of #{file_path} with #{line_processor} :")

        file_reader = file_reader_class.new(file_path, file_header_mapping, keep_nil: false)
        file_reader.line_processing do |line|
          line_import = line_processor.call(data: line)
          log_import_error(line_import, file_path, logger)
          return false if line_import.failure?
        end

        logger.info("Import of file #{file_path} is complete !")
      end

      def bulk_import(file_path, file_header_mapping, imported_model)
        logger.info("Starting bulk import of #{imported_model} from `#{file_path}`:")
        file_reader = file_reader_class.new(file_path, file_header_mapping, keep_nil: true)
        file_reader.bulk_processing { |batch| imported_model.import(batch) }
        logger.info("Import of file #{file_path} is complete!")
      end

      def log_import_error(line_import, file_path, logger)
        if line_import.failure?
          logger.error(line_import[:error])
          logger.error("Fail to import file `#{file_path}`.")
        else
          logger.warn(line_import[:warning]) unless line_import[:warning].nil?
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
