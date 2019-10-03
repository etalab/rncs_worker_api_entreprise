module TribunalInstance
  module Stock
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
          units_hash = stock_units_path.map do |unit_path|
            create_unit(stock, unit_path)
          end

          # group by code_greffe, number, wildcard
          # its merge xx_lot01, xx_lot02 in xx_lot*
          units_hash.uniq!
          units_hash.each { |unit| stock.stock_units.create(unit) }

          ctx[:stock_units] = stock.stock_units
        rescue DeserializeError
          false
        end

        private

        def create_unit(stock, unit_path)
          match = unit_path.match(%r{\A#{stock.files_path}/(\d{4})_S(\d)_\d{8}_lot\d{2}\.zip\Z})
          raise DeserializeError unless match

          code_greffe, unit_number = match.captures

          {
            code_greffe: code_greffe,
            number: unit_number,
            file_path: unit_path.gsub(/lot\d{2}/, 'lot*'),
            status: 'PENDING'
          }
        end
      end
    end
  end
end
