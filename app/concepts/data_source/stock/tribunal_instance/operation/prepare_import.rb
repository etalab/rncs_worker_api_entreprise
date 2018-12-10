module DataSource
  module Stock
    module TribunalInstance
      module Operation
        class PrepareImport < Trailblazer::Operation
          class DeserializeError < StandardError; end

          step :fetch_stock_units
          fail ->(ctx, stock:, **) { ctx[:error] = "No stock units found in #{stock.files_path}." }, fail_fast: true

          step :deserialize_stock_units
          fail ->(ctx, stock:, **) { ctx[:error] = "Unexpected filenames in #{stock.files_path}." }
          step :group_file_infos_by_greffe
          step :persist_stock_units

          def fetch_stock_units(ctx, stock:, **)
            ctx[:stock_units_path] = Dir.glob(stock.files_path + '/*.zip')
            !ctx[:stock_units_path].empty?
          end

          def deserialize_stock_units(ctx, stock:, stock_units_path:, **)
            begin
              files_infos = stock_units_path.map do |unit_path|
                if match = unit_path.match(/\A#{stock.files_path}\/(\d{4})_S(\d)_\d{8}_lot\d{2}\.zip\Z/)
                  code_greffe, unit_number = match.captures

                  {
                    code_greffe: code_greffe,
                    number: unit_number,
                    file_path: unit_path
                  }
                else
                  raise DeserializeError
                end
              end

              ctx[:files_infos] = files_infos
            rescue DeserializeError
              false
            end
          end

          def group_file_infos_by_greffe(ctx, files_infos:, **)
            ctx[:file_infos_grouped] = files_infos.group_by do |info|
              {
                code_greffe: info[:code_greffe],
                number: info[:number]
              }
            end
          end

          def persist_stock_units(ctx, stock:, file_infos_grouped:, **)
            file_infos_grouped.each do |key, values|

              wildcard = wildcard_from values

              stock.stock_units.create(
                code_greffe: key[:code_greffe],
                number: key[:number],
                file_path: wildcard,
                status: 'PENDING'
              )
            end

            ctx[:stock_units] = stock.stock_units
          end

          private

          def wildcard_from(paths)
            wildcard = paths.map do |info|
              info[:file_path].gsub(/lot\d{2}/, 'lot*')
            end

            wildcard.uniq.first
          end
        end
      end
    end
  end
end
