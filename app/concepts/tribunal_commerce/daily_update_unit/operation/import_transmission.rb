module TribunalCommerce
  module DailyUpdateUnit
    module Operation
      class ImportTransmission < Trailblazer::Operation
        include TribunalCommerce::Helper::DataFile

        step :fetch_files_from_folder
        step :read_files_metadata
        step :retrieve_import_workers
        step :order_files_import
        step :import


        def fetch_files_from_folder(ctx, files_path:, **)
          ctx[:files_list] = fetch_from_folder(files_path)
          ctx[:files_list].any?
        end

        def read_files_metadata(ctx, files_list:, **)
          ctx[:files_args] = parse_flux_filename(files_list)
        end

        def retrieve_import_workers(ctx, files_args:, **)
          ctx[:files_args] = map_import_worker(files_args)
        end

        def order_files_import(ctx, files_args:, **)
          files_args.sort_by! { |e| e[:run_order] }
        end

        def import(ctx, files_args:, logger:, **)
          files_args.each do |arg|
            label = arg[:label]
            import_worker = arg[:import_worker]
            filename = arg[:path].split('/').last

            unless ['actes', 'comptes_annuels'].include?(label)
              logger.info("Starting import of file #{filename}...")
              file_import = import_worker.call(file_path: arg[:path], type_import: :flux, logger: logger)

              if file_import.success?
                logger.info("Import of file #{filename} is complete")
              else
                logger.error("Import of file #{filename} failed. Aborting import...")
                return false
              end
            end
          end

          logger.info('All files have been successfuly imported !')
        end
      end
    end
  end
end
