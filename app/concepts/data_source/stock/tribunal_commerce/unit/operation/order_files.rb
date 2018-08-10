module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class OrderFiles
            class << self
              def call(ctx, stock_list:, **)
                return false if stock_list.any? { |e| e[:run_order].nil? }
                stock_list.sort_by! { |e| e[:run_order].to_i }
              end
            end
          end
        end
      end
    end
  end
end
