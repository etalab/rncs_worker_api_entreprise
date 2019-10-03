module TribunalCommerce
  module DailyUpdate
    module Operation
      class FetchPartialStocksInPipe < Trailblazer::Operation
        extend ClassDependencies

        self[:partial_stock_folder] = ::File.join(Rails.configuration.rncs_sources_path, 'tc', 'stock')

        step :fetch_updates
        step :deserialize

        def fetch_updates(ctx, partial_stock_folder:, **)
          # Flux are located in subfolders following the 'AAAA/MM/DD' pattern
          pattern = ::File.join(partial_stock_folder, '*', '*', '*')
          stock_paths = Dir.glob(pattern)
          ctx[:partial_stock_path_list] = stock_paths
        end

        def deserialize(ctx, partial_stock_path_list:, partial_stock_folder:, **)
          partial_stocks = partial_stock_path_list.map do |stock_path|
            return false unless (match = stock_path.match(%r{\A#{partial_stock_folder}/(.{4})/(.{2})/(.{2})\Z}))

            year, month, day = match.captures
            DailyUpdateTribunalCommerce.new(
              year: year,
              month: month,
              day: day,
              files_path: stock_path,
              partial_stock: true
            )
          end

          ctx[:partial_stocks] = partial_stocks
        end
      end
    end
  end
end
