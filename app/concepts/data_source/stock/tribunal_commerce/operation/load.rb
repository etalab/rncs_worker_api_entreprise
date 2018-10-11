module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Load < Trailblazer::Operation
          include TrailblazerHelper::DBIndexes

          step Nested(RetrieveLastStock)
          step ->(ctx, stock:, **) { stock.newer? }
          step ->(ctx, stock:, **) { stock.save }
          step Nested(PrepareImport)
          step :drop_db_index
          step Import


          def drop_db_index(ctx, **)
            drop_queries.each { |query| ActiveRecord::Base.connection.execute(query) }
          end
        end
      end
    end
  end
end
