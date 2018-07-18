module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class ImportFromSourceDir < Trailblazer::Operation
          step :fetch_all_source_archives
          step :prepare_import
          step :import

          def fetch_all_source_archives(ctx, stock:, **)
            sources_path = Dir.glob(stock.files_path + '/*.zip')
            ctx[:sources_path] = sources_path
          end

          def prepare_import(ctx, sources_path:, stock:, **)
            import_args = sources_path.map do |path|
              if match = path.match(/\A#{stock.files_path}\/(\d{4})_S(\d)_\d{8}\.zip\Z/)
                num_tc, num_stock = match.captures
                name_archive = path.split('/').last.chomp('.zip')

                { num_tc: num_tc, num_stock: num_stock, path: path, name_archive: name_archive }
              else
                # TODO manage errors
              end
            end

            import_args.sort_by! { |a| a[:num_tc] }
            ctx[:args] = import_args
          end

          def import(ctx, args:, **)
            zip_path = args.first[:path]
            extract = ExtractArchive.call(archive_path: zip_path)

            if extract.success?
              stock_file_list = order_stock_list(extract[:extracted_files])

              stock_file_list.map do |file|
                filename = file[:filename]
                store_runner = file[:file_mapper]
                store = store_runner.call(file_path: filename) unless ['actes', 'comptes_annuels'].include?(file[:label])
              end
            end

            `rm -rf #{zip_path.chomp('.zip')}`
          end

          def order_stock_list(filename_list)
            ordered_list = filename_list.map do |filename|
              if match = filename.match(/\A.+\/(.+)\/\1_(\d+)_(.+)\.csv\Z/)
                _, num_stock, label = match.captures
                file_mapper = file_mapper_for(label)

                { filename: filename, run_priority: num_stock, label: label, file_mapper: file_mapper }
              else
                # TODO manage errors
              end
            end

            ordered_list.sort_by { |a| a[:run_priority].to_i }
          end

          def file_mapper_for(file_label)
            case file_label
            when 'PM'
              DataSource::File::PM::Operation::Store

            when 'PP'
              DataSource::File::PP::Operation::Store

            when 'rep'
              DataSource::File::Rep::Operation::Store

            when 'ets'
              DataSource::File::Ets::Operation::Store

            when 'obs'
              DataSource::File::Obs::Operation::Store

            when 'actes'
              # DataSource::File::Actes::Operation::Store

            when 'comptes_annuels'
              # DataSource::File::ComptesAnnuels::Operation::Store

            else
            end
          end
        end
      end
    end
  end
end
