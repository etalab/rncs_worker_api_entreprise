module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Import
          class << self
            # TODO rename import_args (now a list of StockUnit models)
            def call(ctx, import_args:, **)
              import_args.each do |stock_unit|
                ImportTcStockUnitJob.perform_later(stock_unit.id)
              end
            end
          end
        end
      end
    end
  end
end
