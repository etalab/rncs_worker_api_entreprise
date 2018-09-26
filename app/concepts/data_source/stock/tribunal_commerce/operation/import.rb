module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Import
          class << self
            def call(ctx, stock_units:, **)
              stock_units.each do |stock_unit|
                ImportTcStockUnitJob.perform_later(stock_unit.id)
              end
            end
          end
        end
      end
    end
  end
end
