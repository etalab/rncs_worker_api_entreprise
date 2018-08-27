module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class RetrieveLastStock < Trailblazer::Operation
          RNCSSourceDir = '/Users/alexandre/Professional/temp_imr/IMR_Donnees_Saisies/IMR_Donnees_Saisies/tc/stock/'

          step :fetch_stocks
          fail ->(ctx, **) { ctx[:errors] = "No stock found into #{RNCSSourceDir}" }, fail_fast: true

          step :deserialize
          fail ->(ctx, stock_path_list:, **) { ctx[:errors] = "Could not deserialize stocks #{stock_path_list}." }, fail_fast: true

          step :most_recent_stock


          def fetch_stocks(ctx, **)
            stocks_paths = Dir.glob("#{RNCSSourceDir}*/*/*")
            ctx[:stock_path_list] = stocks_paths unless stocks_paths.empty?
          end

          # Stocks are located in subfolders following the 'AAAA/MM/DD' pattern
          def deserialize(ctx, stock_path_list:, **)
            stock_list = stock_path_list.map do |path|
              if match = path.match(/\A#{RNCSSourceDir}(.{4})\/(.{2})\/(.{2})\Z/)
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
