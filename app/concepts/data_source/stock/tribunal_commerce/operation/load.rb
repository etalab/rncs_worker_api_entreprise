module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class Load < Trailblazer::Operation
          step Nested(RetrieveLastStock)
          step ->(ctx, stock:, **) { stock.newer? }
          step ->(ctx, stock:, **) { stock.save }
          step Nested(PrepareImport)
          step :drop_db_index
          step Import


          def drop_db_index(ctx, **)
            sql = 'DROP INDEX IF EXISTS index_dossier_entreprise_enregistrement_id'
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end
    end
  end
end
