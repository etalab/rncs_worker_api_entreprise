module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Import
          class << self
            def call(ctx, import_args:, **)
              import_args.each do |stock_unit_args|
                # TODO pass entire `stock_unit_args` to the import job
                ImportTcStockUnitJob.perform_later(stock_unit_args)
              end
            end
          end
        end
      end
    end
  end
end
