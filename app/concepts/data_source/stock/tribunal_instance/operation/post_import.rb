module DataSource
  module Stock
    module TribunalInstance
      module Operation
        class PostImport < Trailblazer::Operation
          include TrailblazerHelper::DBIndexes

          step :import_completed?
          fail ->(ctx, logger:, **) { logger.warn 'Import not completed, skipping index creation' }
          step :create_db_indexes
          pass ->(ctx, logger:, **) { logger.info 'TITMC indexes created' }

          def import_completed?(ctx, stock_unit:, **)
            overall_import = stock_unit.stock
            overall_import.status == 'COMPLETED'
          end

          def create_db_indexes(ctx, **)
            create_queries(:tribunal_instance).each { |query| ActiveRecord::Base.connection.execute(query) }
          end
        end
      end
    end
  end
end
