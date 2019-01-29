module TribunalCommerce
  module Helper
    module DataFile
      class UnknownFileLabel < StandardError; end
      class UnexpectedFilename < StandardError; end

      def fetch_from_folder(folder_path)
        pattern = ::File.join(folder_path, '*.csv')
        Dir.glob(pattern)
      end

      def parse_flux_filename(file_list_paths)
        data = file_list_paths.map do |file_path|
          filename = file_path.split('/').last

          if match = filename.match(flux_filename_regex)
            code_greffe, num_transmission, date, hour, run_order, label = match.captures

            {
              code_greffe: code_greffe,
              run_order: run_order.to_i,
              label: label,
              path: file_path
            }
          else
            raise UnexpectedFilename, "Cannot parse filename : \"#{filename}\" does not match the expected pattern"
          end
        end
        data
      end

      def parse_stock_filename(file_list_paths)
        data = file_list_paths.map do |file_path|
          filename = file_path.split('/').last

          if match = filename.match(stock_filename_regex)
            code_greffe, num_stock, date, run_order, label = match.captures

            {
              code_greffe: code_greffe,
              run_order: run_order.to_i,
              label: label,
              path: file_path
            }
          else
            raise UnexpectedFilename, "Cannot parse filename : \"#{filename}\" does not match the expected pattern"
          end
        end
        data
      end

      def map_import_worker(files_args)
        result = files_args.map do |file_arg|
          file_arg[:import_worker] = fetch_worker_for(file_arg[:label])
          file_arg
        end
        result
      end

      private

      def flux_filename_regex
        /\A(\d{4})_(\d{1,})_(\d{8})_(\d{6})_(\d{1,2})_(.+)\.csv\Z/
      end

      def stock_filename_regex
        /\A(\d{4})_(S\d)_(\d{8})_(\d{1,2})_(.+)\.csv\Z/
      end

      def fetch_worker_for(label)
        case label
        when 'PM'
          DataSource::File::PM::Operation::Import

        when 'PM_EVT'
          TribunalCommerce::File::PMEvent::Operation::Import

        when 'PP'
          DataSource::File::PP::Operation::Import

        when 'PP_EVT'
          TribunalCommerce::File::PPEvent::Operation::Import

        when 'rep'
          DataSource::File::Rep::Operation::Import

        when 'rep_nouveau_modifie_EVT'
          TribunalCommerce::File::RepNouveauModifie::Operation::Import

        when 'rep_partant_EVT'
          TribunalCommerce::File::RepPartant::Operation::Import

        when 'ets'
          DataSource::File::Ets::Operation::Import

        when 'ets_nouveau_modifie_EVT'
          TribunalCommerce::File::EtsNouveauModifie::Operation::Import

        when 'ets_supprime_EVT'
          TribunalCommerce::File::EtsSupprime::Operation::Import

        when 'obs'
          DataSource::File::Obs::Operation::Import

        when 'actes'
        when 'comptes_annuels'

        else
          raise UnknownFileLabel, "Unknown file label \"#{label}\""
        end
      end
    end
  end
end
