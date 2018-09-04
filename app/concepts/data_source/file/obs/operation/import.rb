module DataSource
  module File
    module Obs
      module Operation
        class Import
          class << self
            def call(ctx, file_path:, code_greffe:, **)
              known_sirens = retrieve_all_siren_for_greffe(code_greffe)
              ::File.open(file_path, 'r:bom|utf-8') do |f|
                SmarterCSV.process(f, csv_options) do |batch|
                  batch_import = Operation::BatchImport.call(raw_data: batch, siren_in_db: known_sirens)
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

            def retrieve_all_siren_for_greffe(code_greffe)
              Entreprise.select(:id, :siren).where(code_greffe: code_greffe).to_a.pluck(:siren, :id)
            end
          end
        end
      end
    end
  end
end
