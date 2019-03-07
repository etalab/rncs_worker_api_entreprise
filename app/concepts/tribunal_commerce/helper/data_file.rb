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

      private

      def flux_filename_regex
        /\A(\d{4})_(\d{1,})_(\d{8})_(\d{6})_(\d{1,2})_(.+)\.csv\Z/
      end

      def stock_filename_regex
        /\A(\d{4})_(S\d)_(\d{8})_(\d{1,2})_(.+)\.csv\Z/
      end
    end
  end
end
