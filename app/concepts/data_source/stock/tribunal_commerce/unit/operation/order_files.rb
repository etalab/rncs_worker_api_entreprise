module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class OrderFiles
            class << self
              def call(ctx, stock_files:, **)
                return false if stock_files.any? { |e| e[:run_order].nil? }
                stock_files.sort_by! { |e| e[:run_order].to_i }
              end
            end
          end
        end
      end
    end
  end
end
