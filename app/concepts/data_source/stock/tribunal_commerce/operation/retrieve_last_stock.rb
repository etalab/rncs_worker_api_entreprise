module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class RetrieveLastStock < Trailblazer::Operation
          RNCSSourceDir = '/Users/alexandre/Professional/temp_imr/IMR_Donnees_Saisies/tc/stock/'

          step :fetch_last_stock_from_source_dir

          def fetch_last_stock_from_source_dir(ctx, **)
            source_dir_stocks = Dir.glob("#{RNCSSourceDir}*/*/*")
            stocks = deserialize_stocks(source_dir_stocks)
            ctx[:stock] = stocks.max { |a, b| a.date <=> b.date }
          end

          def deserialize_stocks(fs_stock_list)
            stocks = fs_stock_list.map do |dump|
              if match = dump.match(/\A#{RNCSSourceDir}(.{4})\/(.{2})\/(.{2})\Z/)
                year, month, day = match.captures
                StockTribunalCommerce.new(year: year, month: month, day: day, files_path: dump)
              else
                # TODO manage errors
              end
            end

            stocks
          end
        end
      end
    end
  end
end
