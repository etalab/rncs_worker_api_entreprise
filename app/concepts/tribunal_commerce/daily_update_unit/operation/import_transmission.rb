module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class ImportTransmission < Trailblazer::Operation
        include TribunalCommerce::Helper::DataFile

        step ->(ctx, logger:, file_importer:nil, **) do
          ctx[:file_importer] = TribunalCommerce::Helper::FileImporter.new(logger) if file_importer.nil?
          true
        end

        step :fetch_files_from_folder
        step :read_files_metadata
        step :rename_rep_files_headers

        step :import_dossiers_entreprise_from_pm
        step :import_personnes_morales
        step :import_dossiers_entreprise_evt_from_pm
        step :import_personnes_morales_evt
        step :import_dossiers_entreprise_from_pp
        step :import_personnes_physiques
        step :import_dossiers_entreprise_evt_from_pp
        step :import_personnes_physiques_evt
        step :import_representants
        step :import_representants_nouveau_modifie
        step :import_representants_partant
        step :import_etablissements
        step :import_etablissements_nouveau_modifie
        step :import_etablissements_supprime
        step :import_observations

        step :log_transmission_import_complete
        fail :log_transmission_import_failure

        def fetch_files_from_folder(ctx, files_path:, **)
          ctx[:files_list] = fetch_from_folder(files_path)
          ctx[:files_list].any?
        end

        def read_files_metadata(ctx, files_list:, **)
          ctx[:files_args] = parse_flux_filename(files_list)
        end

        def rename_rep_files_headers(ctx, files_args:, **)
          files_args.each do |arg|
            if /rep/.match?(arg[:label])
              # for sed portability on different OS : see https://stackoverflow.com/questions/5171901/sed-command-find-and-replace-in-file-and-overwrite-file-doesnt-work-it-empties
              # some CSV files may contains quoted headers...
              file_path = arg[:path]
              tmp_file = file_path + '.tmp'
              `sed -E -e '1s/"?Nom_Greffe"?;"?Numero_Gestion"?;"?Siren"?;"?Type"?;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path} > #{tmp_file} && mv #{tmp_file} #{file_path}`
            end
          end
        end

        def import_dossiers_entreprise_from_pm(ctx, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          file_importer.import_dossiers_entreprise_from_pm(pm_file_path)
        end

        def import_personnes_morales(ctx, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          file_importer.import_personnes_morales(pm_file_path)
        end

        def import_dossiers_entreprise_evt_from_pm(ctx, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM_EVT')
          file_importer.import_dossiers_entreprise_evt_from_pm(pm_file_path)
        end

        def import_personnes_morales_evt(ctx, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM_EVT')
          file_importer.import_personnes_morales_evt(pm_file_path)
        end

        def import_dossiers_entreprise_from_pp(ctx, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          file_importer.import_dossiers_entreprise_from_pp(pp_file_path)
        end

        def import_personnes_physiques(ctx, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          file_importer.import_personnes_physiques(pp_file_path)
        end

        def import_dossiers_entreprise_evt_from_pp(ctx, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP_EVT')
          file_importer.import_dossiers_entreprise_evt_from_pp(pp_file_path)
        end

        def import_personnes_physiques_evt(ctx, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP_EVT')
          file_importer.import_personnes_physiques_evt(pp_file_path)
        end

        def import_representants(ctx, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep')
          file_importer.import_representants(rep_file_path)
        end

        def import_representants_nouveau_modifie(ctx, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep_nouveau_modifie_EVT')
          file_importer.import_representants_nouveau_modifie(rep_file_path)
        end

        def import_representants_partant(ctx, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep_partant_EVT')
          file_importer.import_representants_partant(rep_file_path)
        end

        def import_etablissements(ctx, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets')
          file_importer.import_etablissements(ets_file_path)
        end

        def import_etablissements_nouveau_modifie(ctx, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets_nouveau_modifie_EVT')
          file_importer.import_etablissements_nouveau_modifie(ets_file_path)
        end

        def import_etablissements_supprime(ctx, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets_supprime_EVT')
          file_importer.import_etablissements_supprime(ets_file_path)
        end

        def import_observations(ctx, files_args:, file_importer:, logger:, **)
          obs_file_path = extract_file_path(files_args, 'obs')
          file_importer.import_observations(obs_file_path)
        end

        def log_transmission_import_complete(ctx, logger:, **)
          logger.info('All files have been successfuly imported !')
        end

        def log_transmission_import_failure(ctx, logger:, **)
          logger.error('An error occured while importing a file, abort import of transmission...')
        end

        # TODO Move this into its own class (a class containing the logic to parse
        # file names, storing the files_args hash and allowing to retrieve the path
        # from the label)
        def extract_file_path(files_args, label)
          files_args.find { |file_args| file_args[:label] == label }
            .yield_self { |it| it[:path] }
        end
      end
    end
  end
end
