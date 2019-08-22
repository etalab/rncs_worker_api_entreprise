module TribunalCommerce
  module Stock
    module Operation
      class Import < Trailblazer::Operation
        extend ClassDependencies
        include TrailblazerHelper::DBIndexes

        self[:stocks_folder] = ::File.join(Rails.configuration.rncs_sources_path, 'tc/stock')
        self[:logger] = Rails.logger

        step :log_import_start
        step :stock_exists?
          fail :log_stock_not_found, fail_fast: true
        step :save_new_stock
        step :fetch_related_stock_units
          fail :rollback_created_stock, fail_fast: true
        step :drop_db_index
        step ->(ctx, logger:, **) { logger.info('Creating jobs to import each greffe\'s unit synchronously...') }
        step :import

        def drop_db_index(ctx, **)
          drop_queries(:tribunal_commerce).each { |query| ActiveRecord::Base.connection.execute(query) }
        end

        def stock_exists?(ctx, stock_args:, stocks_folder:, **)
          stock_path = "#{stock_args[:year]}/#{stock_args[:month]}/#{stock_args[:day]}"
          ctx[:stock_absolute_path] = ::File.join(stocks_folder, stock_path)
          Dir.exists?(ctx[:stock_absolute_path])
        end

        def save_new_stock(ctx, stock_args:, stock_absolute_path:, **)
          ctx[:new_stock] = StockTribunalCommerce.create(
            year: stock_args[:year],
            month: stock_args[:month],
            day: stock_args[:day],
            files_path: stock_absolute_path,
          )
        end

        def fetch_related_stock_units(ctx, new_stock:, logger:, **)
          greffe_units = Dir.glob("#{new_stock.files_path}/*.zip")
          greffe_units.each do |unit_path|
            if match = unit_path.match(/\A.+\/(\d{4})_S(\d)_\d{8}\.zip\Z/)
              code_greffe, unit_number = match.captures

              new_stock.stock_units.create(
                code_greffe: code_greffe,
                number: unit_number,
                file_path: unit_path,
                status: 'PENDING'
              )
            else
              logger.error("Unexpected stock unit found : `#{unit_path}`. Aborting...")
              return false
            end
          end

          return true
        end

        def import(ctx, new_stock:, **)
          new_stock.stock_units.each do |unit|
            ImportTCStockUnitJob.perform_later(unit.id)
          end
        end

        def log_stock_not_found(ctx, logger:, stock_absolute_path:, **)
          logger.error("Specified stock #{stock_absolute_path} is not found. Ensure the stock to import exists. Aborting...")
        end

        def log_import_start(ctx, logger:, stock_args:, **)
          stock_name = "#{stock_args[:year]}/#{stock_args[:month]}/#{stock_args[:day]}"
          logger.info("Starting import : looking for stock #{stock_name} in file system...")
        end

        def rollback_created_stock(ctx, new_stock:, **)
          new_stock.destroy
        end
      end
    end
  end
end
