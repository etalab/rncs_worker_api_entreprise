module DataSource
  module File
    module Operation
      class Import
        class << self
          def call(ctx, params:, logger:, **)
            batch_counter = 1
            import_worker = params[:import_worker]

            if ['rep', 'ets', 'obs'].include?(params[:file_label])
              known_sirens = retrieve_all_siren_for_greffe(params[:code_greffe])
            else
              known_sirens = nil
            end

            ::File.open(params[:file_path], 'r:bom|utf-8') do |f|
              SmarterCSV.process(f, csv_options) do |batch|
                logger.info("Processing batch number #{batch_counter}")
                batch_import = import_worker.call(raw_data: batch, siren_in_db: known_sirens)
                batch_counter += 1

                if batch_import.success?
                  logger.info("Batch number #{batch_counter} run with success.")
                else
                  logger.error("Error encountered running batch number #{batch_counter}.")
                end
              end
            end
          end

          # EOFError whe file is empty

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
