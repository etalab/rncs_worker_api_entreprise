module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class MapFileLoader
            class MapError < StandardError; end

            class << self
              def call(ctx, stock_files:, **)
                begin
                  stock_files.each do |file_param|
                    if file_param[:label].nil?
                      raise MapError, 'Incomming params does not have :label key'
                    else
                      file_param[:loader] = fetch_loader(file_param[:label])
                    end
                  end

                rescue MapError
                  false
                end
              end

              private

              def fetch_loader(file_label)
                case file_label
                when 'PM'
                  DataSource::File::PM::Operation::Load

                # TODO add loader when implemented
                when 'PP'
                  DataSource::File::PP::Operation::Load
                when 'rep'
                when 'ets'
                when 'obs'
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
