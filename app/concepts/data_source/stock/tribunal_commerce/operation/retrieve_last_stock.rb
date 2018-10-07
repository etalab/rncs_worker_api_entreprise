module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class RetrieveLastStock < Trailblazer::Operation
          extend ClassDependencies

          self[:stocks_folder] = ::File.join(Rails.application.config_for(:rncs_sources)['path'], 'tc', 'stock')

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

          def deserialize(ctx, stock_path_list:, stocks_folder:, **)
            stock_list = stock_path_list.map do |path|
              if match = path.match(/\A#{stocks_folder}\/(.{4})\/(.{2})\/(.{2})\Z/)
                year, month, day = match.captures
                StockTribunalCommerce.new(year: year, month: month, day: day, files_path: path)
              else
                return false
              end
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
end
