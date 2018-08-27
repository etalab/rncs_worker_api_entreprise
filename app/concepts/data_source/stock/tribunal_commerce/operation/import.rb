module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Import
          class << self
            def call(ctx, import_args:, **)
              errors = []
              import_args.each do |stock_unit_args|
                import_stock_unit = DataSource::Stock::TribunalCommerce::Unit::Operation::Load.call(stock_unit_path: stock_unit_args[:path])

                if import_stock_unit.failure?
                  errors.push "Errors encountered on while importing unit `#{stock_unit_args[:name]}`."
                end
              end

              ctx[:errors] = errors unless errors.empty?
              errors.empty?
            end
          end
        end
      end
    end
  end
end
