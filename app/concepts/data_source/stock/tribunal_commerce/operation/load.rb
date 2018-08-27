module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Load < Trailblazer::Operation
          step Nested(RetrieveLastStock)
          step ->(ctx, stock:, **) { stock.newer? }
          step Nested(PrepareImport)
        end
      end
    end
  end
end
