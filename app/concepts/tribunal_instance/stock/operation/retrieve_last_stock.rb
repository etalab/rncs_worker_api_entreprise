module TribunalInstance
  module Stock
    module Operation
      class RetrieveLastStock < Trailblazer::Operation
        # ctx should have stocks_folder & stock_class
        step :fetch_stocks
        step :deserialize
        fail ->(ctx, stocks_folder:, **) { ctx[:error] = "No stock found inside #{stocks_folder}. Ensure the folder exists with a valid subfolder structure." }
        step :most_recent_stock

        def fetch_stocks(ctx, stocks_folder:, **)
          # Stocks are located in subfolders following the 'AAAA/MM/DD' pattern
          stocks_paths_pattern = ::File.join(stocks_folder, '*', '*', '*')
          stocks_paths = Dir.glob(stocks_paths_pattern)
          ctx[:stock_path_list] = stocks_paths unless stocks_paths.empty?
        end

        def deserialize(ctx, stock_path_list:, stocks_folder:, stock_class:, **)
          stock_list = stock_path_list.map do |path|
            return false unless (match = path.match(%r{\A#{stocks_folder}/(.{4})/(.{2})/(.{2})\Z}))

            year, month, day = match.captures
            stock_class.new(year: year, month: month, day: day, files_path: path)
          end

          ctx[:stock_list] = stock_list
        end

        def most_recent_stock(ctx, stock_list:, **)
          ctx[:stock] = stock_list.max { |a, b| a.date <=> b.date }
        end
      end
    end
  end
end
