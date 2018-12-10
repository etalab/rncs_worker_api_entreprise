module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Load < Trailblazer::Operation
          extend ClassDependencies
          include TrailblazerHelper::DBIndexes

          self[:stocks_folder] = ::File.join(Rails.configuration.rncs_sources['path'], 'tc', 'stock')
          self[:stock_class] = StockTribunalCommerce

          step Nested(::DataSource::Stock::Task::RetrieveLastStock)
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
