module TribunalInstance
  module Stock
    module Operation
      class PostImport < Trailblazer::Operation
        include TrailblazerHelper::DBIndexes

        step :import_completed?
        fail ->(_, logger:, **) { logger.warn('Import not completed, skipping index creation') }
        step :create_db_indexes
        pass ->(_, logger:, **) { logger.info('TITMC indexes created') }

        def import_completed?(_, stock_unit:, **)
          overall_import = stock_unit.stock
          overall_import.status == 'COMPLETED'
        end

        def create_db_indexes(_, **)
          create_queries(:tribunal_instance).each { |query| ActiveRecord::Base.connection.execute(query) }
        end
      end
    end
  end
end
