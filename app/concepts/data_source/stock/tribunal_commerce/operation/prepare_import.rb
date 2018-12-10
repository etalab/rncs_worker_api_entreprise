module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class PrepareImport < Trailblazer::Operation
          class DeserializeError < StandardError; end

          step :fetch_stock_units
          fail ->(ctx, stock:, **) { ctx[:error] = "No stock units found in #{stock.files_path}." }, fail_fast: true

          step :deserialize_stock_units
          fail ->(ctx, stock:, **) { ctx[:error] = "Unexpected filenames in #{stock.files_path}." }

          def fetch_stock_units(ctx, stock:, **)
            ctx[:stock_units_path] = Dir.glob(stock.files_path + '/*.zip')
            !ctx[:stock_units_path].empty?
          end

          def deserialize_stock_units(ctx, stock:, stock_units_path:, **)
            begin
              stock_units = stock_units_path.map do |unit_path|
                if match = unit_path.match(/\A#{stock.files_path}\/(\d{4})_S(\d)_\d{8}\.zip\Z/)
                  code_greffe, unit_number = match.captures

                  stock.stock_units.create(
                    code_greffe: code_greffe,
                    number: unit_number,
                    file_path: unit_path,
                    status: 'PENDING'
                  )
                else
                  raise DeserializeError
                end
              end
              ctx[:stock_units] = stock_units

            rescue DeserializeError
              false
            end
          end
        end
      end
    end
  end
end
