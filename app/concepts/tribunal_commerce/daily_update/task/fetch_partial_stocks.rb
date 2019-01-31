module TribunalCommerce
  module DailyUpdate
    module Task
      class FetchPartialStocks < Trailblazer::Operation
        class DeserializeError < StandardError; end

        step :fetch_partial_stock_units
        fail ->(ctx, daily_update:, **) { ctx[:error] = "No units found in #{daily_update.files_path}." }, fail_fast: true

        step :deserialize_partial_stock_units
        fail ->(ctx, daily_update:, **) { ctx[:error] = "Unexpected filenames in #{daily_update.files_path}." }

        def fetch_partial_stock_units(ctx, daily_update:, **)
          ctx[:partial_stocks_path] = Dir.glob(daily_update.files_path + '/*.zip')
          ctx[:partial_stocks_path].any?
        end

        def deserialize_partial_stock_units(ctx, daily_update:, partial_stocks_path:, **)
          begin
            partial_stock_units = partial_stocks_path.map do |unit_path|
              if match = unit_path.match(/\A#{daily_update.files_path}\/(\d{4})_S(\d)_\d{8}\.zip\Z/)
                code_greffe = match.captures.first

                daily_update.daily_update_units.create(
                  code_greffe: code_greffe,
                  files_path: unit_path,
                  status: 'PENDING'
                )
              else
                raise DeserializeError
              end
            end
            ctx[:partial_stock_units] = partial_stock_units

          rescue DeserializeError
            false
          end
        end
      end
    end
  end
end
