module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class PrepareImport < Trailblazer::Operation
          step :fetch_stock_units
          fail ->(ctx, **) { ctx[:error] = 'No stock units found' }, fail_fast: true

          step :deserialize_units_path
          fail ->(ctx, **) { ctx[:error] = 'Unexpected stock unit filename : parse failure' }

          step :order_units_import
          step :drop_db_index


          def fetch_stock_units(ctx, stock:, **)
            ctx[:stock_units_path] = Dir.glob(stock.files_path + '/*.zip')
            !ctx[:stock_units_path].empty?
          end

          def deserialize_units_path(ctx, stock:, stock_units_path:, **)
            import_args = stock_units_path.map do |unit_path|
              if match = unit_path.match(/\A#{stock.files_path}\/(\d{4})_S(\d)_\d{8}\.zip\Z/)
                code_greffe, unit_number = match.captures
                unit_name = unit_path.split('/').last.chomp('.zip')

                { code_greffe: code_greffe, unit_number: unit_number, path: unit_path, name: unit_name }

              else
                # TODO deal with errors
              end
            end

            ctx[:import_args] = import_args
          end

          def order_units_import(ctx, import_args:, **)
            import_args.sort_by! { |e| [e[:code_greffe], e[:unit_number]] }
          end

          def drop_db_index(ctx, **)
            sql = 'DROP INDEX IF EXISTS index_dossier_entreprise_enregistrement_id'
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end
    end
  end
end
