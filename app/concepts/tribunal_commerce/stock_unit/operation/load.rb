module TribunalCommerce
  module StockUnit
    module Operation
      class Load < Trailblazer::Operation
        include TribunalCommerce::Helper::DataFile

        step ->(ctx, logger:, file_importer: nil, **) {
          ctx[:file_importer] = TribunalCommerce::Helper::FileImporter.new(logger) if file_importer.nil?
          true
        }

        step ->(_, logger:, stock_unit:, **) { logger.info("Starting import of stock unit #{stock_unit.code_greffe}...") }
        step :prepare_zip_extraction
        step Nested(ZIP::Operation::Extract)
        fail :log_zip_extraction_error, fail_fast: true

        step :read_files_metadata
        fail :log_filenames_parsing_error, fail_fast: true

        step :bulk_import_dossiers_entreprise_from_pm
        step :bulk_import_personnes_morales
        step :bulk_import_dossiers_entreprise_from_pp
        step :bulk_import_personnes_physiques
        step :rename_csv_header_for_rep
        step :bulk_import_representants
        step :bulk_import_etablissements
        step :bulk_import_observations

        def prepare_zip_extraction(ctx, stock_unit:, **)
          ctx[:path] = stock_unit.file_path
        end

        def log_zip_extraction_error(_, stock_unit:, error:, logger:, **)
          logger.error("An error happened while trying to extract unit archive #{stock_unit.file_path} : #{error}")
        end

        def read_files_metadata(ctx, extracted_files:, **)
          ctx[:files_args] = parse_stock_filename(extracted_files)
        rescue TribunalCommerce::Helper::DataFile::UnexpectedFilename => e
          ctx[:error] = e.message
          false
        end

        def log_filenames_parsing_error(_, logger:, error:, **)
          logger.error("An error occured while parsing unit's files : #{error}")
        end

        def bulk_import_dossiers_entreprise_from_pm(_, files_args:, file_importer:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          file_importer.bulk_import_dossiers_entreprise_from_pm(pm_file_path)
        end

        def bulk_import_dossiers_entreprise_from_pp(_, files_args:, file_importer:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          file_importer.bulk_import_dossiers_entreprise_from_pp(pp_file_path)
        end

        def bulk_import_personnes_morales(_, files_args:, file_importer:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          file_importer.bulk_import_personnes_morales(pm_file_path)
        end

        def bulk_import_personnes_physiques(_, files_args:, file_importer:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          file_importer.bulk_import_personnes_physiques(pp_file_path)
        end

        def bulk_import_representants(_, files_args:, file_importer:, **)
          rep_file_path = extract_file_path(files_args, 'rep')
          file_importer.bulk_import_representants(rep_file_path)
        end

        def bulk_import_etablissements(_, files_args:, file_importer:, **)
          ets_file_path = extract_file_path(files_args, 'ets')
          file_importer.bulk_import_etablissements(ets_file_path)
        end

        def bulk_import_observations(_, files_args:, file_importer:, **)
          obs_file_path = extract_file_path(files_args, 'obs')
          file_importer.bulk_import_observations(obs_file_path)
        end

        def rename_csv_header_for_rep(_, files_args:, **)
          file_path = extract_file_path(files_args, 'rep')
          # for sed portability on different OS : see https://stackoverflow.com/questions/5171901/sed-command-find-and-replace-in-file-and-overwrite-file-doesnt-work-it-empties
          # some CSV files may contain quoted headers...
          tmp_file = file_path + '.tmp'
          `sed -E -e '1s/"?Nom_Greffe"?;"?Numero_Gestion"?;"?Siren"?;"?Type"?;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path} > #{tmp_file} && mv #{tmp_file} #{file_path}`
        end

        def extract_file_path(files_args, label)
          files_args.find { |file_args| file_args[:label] == label }
            .yield_self { |it| it[:path] }
        end
      end
    end
  end
end
