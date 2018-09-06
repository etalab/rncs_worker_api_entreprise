module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class Load < Trailblazer::Operation
            step ->(ctx, stock_unit_path:, **) { ctx[:path] = stock_unit_path } # TODO NOT
            step Nested(ZIP::Operation::Extract) # Rename the operation into Unit::Operation::Extract
            step ->(ctx, extracted_files:, **) { ctx[:raw_stock_files] = extracted_files } # TODO NOT
            step ReadFilesMetadata
            step MapImportWorker
            step OrderFiles
            # TODO delete records from database where code_greffe
            # try to wrap it into a transaction
            step Import
            step ->(ctx, dest_directory:, **) { FileUtils.rm_rf(dest_directory) }
          end
        end
      end
    end
  end
end
