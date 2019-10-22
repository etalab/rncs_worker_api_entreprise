# rubocop:disable Metrics/ClassLength
module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class ImportTransmission < Trailblazer::Operation
        include TribunalCommerce::Helper::DataFile

        step ->(ctx, logger:, file_importer: nil, **) {
          ctx[:file_importer] = TribunalCommerce::Helper::FileImporter.new(logger) if file_importer.nil?
          true
        }

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

        def rename_rep_files_headers(_, files_args:, **)
          files_args.each do |arg|
            next unless /rep/.match?(arg[:label])

            # for sed portability on different OS : see https://stackoverflow.com/questions/5171901/sed-command-find-and-replace-in-file-and-overwrite-file-doesnt-work-it-empties
            # some CSV files may contains quoted headers...
            file_path = arg[:path]
            tmp_file = file_path + '.tmp'
            `sed -E -e '1s/"?Nom_Greffe"?;"?Numero_Gestion"?;"?Siren"?;"?Type"?;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path} > #{tmp_file} && mv #{tmp_file} #{file_path}`
          end
        end

        # TODO: XXX Move logger logic into FileIMporter class, along with `extract_file_path`
        # method
        def import_dossiers_entreprise_from_pm(_, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          if pm_file_path.nil?
            logger.info('Nothing to import from PM : no file present in the transmission. Continue...')
          else
            file_importer.import_dossiers_entreprise_from_pm(pm_file_path)
          end
        end

        def import_personnes_morales(_, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM')
          if pm_file_path.nil?
            logger.info('Nothing to import from PM : no file present in the transmission. Continue...')
          else
            file_importer.import_personnes_morales(pm_file_path)
          end
        end

        def import_dossiers_entreprise_evt_from_pm(_, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM_EVT')
          if pm_file_path.nil?
            logger.info('Nothing to import from PM_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_dossiers_entreprise_evt_from_pm(pm_file_path)
          end
        end

        def import_personnes_morales_evt(_, files_args:, file_importer:, logger:, **)
          pm_file_path = extract_file_path(files_args, 'PM_EVT')
          if pm_file_path.nil?
            logger.info('Nothing to import from PM_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_personnes_morales_evt(pm_file_path)
          end
        end

        def import_dossiers_entreprise_from_pp(_, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          if pp_file_path.nil?
            logger.info('Nothing to import from PP : no file present in the transmission. Continue...')
          else
            file_importer.import_dossiers_entreprise_from_pp(pp_file_path)
          end
        end

        def import_personnes_physiques(_, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP')
          if pp_file_path.nil?
            logger.info('Nothing to import from PP : no file present in the transmission. Continue...')
          else
            file_importer.import_personnes_physiques(pp_file_path)
          end
        end

        def import_dossiers_entreprise_evt_from_pp(_, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP_EVT')
          if pp_file_path.nil?
            logger.info('Nothing to import from PP_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_dossiers_entreprise_evt_from_pp(pp_file_path)
          end
        end

        def import_personnes_physiques_evt(_, files_args:, file_importer:, logger:, **)
          pp_file_path = extract_file_path(files_args, 'PP_EVT')
          if pp_file_path.nil?
            logger.info('Nothing to import from PP_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_personnes_physiques_evt(pp_file_path)
          end
        end

        def import_representants(_, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep')
          if rep_file_path.nil?
            logger.info('Nothing to import from REP : no file present in the transmission. Continue...')
          else
            file_importer.import_representants(rep_file_path)
          end
        end

        def import_representants_nouveau_modifie(_, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep_nouveau_modifie_EVT')
          if rep_file_path.nil?
            logger.info('Nothing to import from rep_nouveau_modifie_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_representants_nouveau_modifie(rep_file_path)
          end
        end

        def import_representants_partant(_, files_args:, file_importer:, logger:, **)
          rep_file_path = extract_file_path(files_args, 'rep_partant_EVT')
          if rep_file_path.nil?
            logger.info('Nothing to import from rep_partant_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_representants_partant(rep_file_path)
          end
        end

        def import_etablissements(_, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets')
          if ets_file_path.nil?
            logger.info('Nothing to import from ets : no file present in the transmission. Continue...')
          else
            file_importer.import_etablissements(ets_file_path)
          end
        end

        def import_etablissements_nouveau_modifie(_, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets_nouveau_modifie_EVT')
          if ets_file_path.nil?
            logger.info('Nothing to import from ets_nouveau_modifie_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_etablissements_nouveau_modifie(ets_file_path)
          end
        end

        def import_etablissements_supprime(_, files_args:, file_importer:, logger:, **)
          ets_file_path = extract_file_path(files_args, 'ets_supprime_EVT')
          if ets_file_path.nil?
            logger.info('Nothing to import from ets_supprime_EVT : no file present in the transmission. Continue...')
          else
            file_importer.import_etablissements_supprime(ets_file_path)
          end
        end

        def import_observations(_, files_args:, file_importer:, logger:, **)
          obs_file_path = extract_file_path(files_args, 'obs')
          if obs_file_path.nil?
            logger.info('Nothing to import from obs : no file present in the transmission. Continue...')
          else
            file_importer.import_observations(obs_file_path)
          end
        end

        def log_transmission_import_complete(_, logger:, **)
          logger.info('All files have been successfuly imported !')
        end

        def log_transmission_import_failure(_, logger:, **)
          logger.error('An error occured while importing a file, abort import of transmission...')
        end

        # TODO: Move this into its own class (a class containing the logic to parse
        # file names, storing the files_args hash and allowing to retrieve the path
        # from the label)
        def extract_file_path(files_args, label)
          files_args.find { |file_args| file_args[:label] == label }
            .yield_self { |it| it.nil? ? nil : it[:path] }
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
