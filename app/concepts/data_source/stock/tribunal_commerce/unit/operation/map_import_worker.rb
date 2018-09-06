module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class MapImportWorker
            class MapError < StandardError; end

            class << self
              def call(ctx, stock_files:, **)
                begin
                  stock_files.each do |file_param|
                    if file_param[:label].nil?
                      raise MapError, 'Incomming params does not have :label key'
                    else
                      file_param[:import_worker] = fetch_import_worker(file_param[:label])
                    end
                  end

                rescue MapError
                  false
                end
              end

              private

              def fetch_import_worker(file_label)
                case file_label
                when 'PM'
                  DataSource::File::PM::Operation::BatchImport

                # TODO add loader when implemented
                when 'PP'
                  DataSource::File::PP::Operation::BatchImport
                when 'rep'
                  DataSource::File::Rep::Operation::BatchImport
                when 'ets'
                  DataSource::File::Ets::Operation::BatchImport
                when 'obs'
                  DataSource::File::Obs::Operation::BatchImport
                when 'actes'
                when 'comptes_annuels'

                else
                  raise MapError, "Error : unknown label `#{file_label}`."
                end
              end
            end
          end
        end
      end
    end
  end
end
