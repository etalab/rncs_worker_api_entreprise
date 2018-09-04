module DataSource
  module File
    module Ets
      module Operation
        class Import
          class << self
            def call(ctx, file_path:, **)
              ::File.open(file_path, 'r:bom|utf-8') do |f|
                SmarterCSV.process(f, csv_options) do |batch|
                  batch_import = Operation::BatchImport.call(raw_data: batch)
                end
              end
            end


            private

            def csv_options
              {
                col_sep: ';',
                remove_empty_values: false,
                chunk_size: Rails.configuration.rncs_sources['import_batch_size']
              }
            end
          end
        end
      end
    end
  end
end
