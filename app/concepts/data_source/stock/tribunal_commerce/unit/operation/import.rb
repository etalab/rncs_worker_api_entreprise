module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class Import
            class << self
              def call(ctx, stock_files:, **)
                errors = []
                stock_files.each do |file|
                  unless ['actes', 'comptes_annuels'].include?(file[:label])
                    import = DataSource::File::Operation::Load.call(params: {
                      file_path: file[:path],
                      file_label: file[:label],
                      import_worker: file[:import_worker],
                      code_greffe: file[:code_greffe],
                      name: file[:name]
                    })

                    if import.failure?
                      errors.push "Errors encountered on import : #{file[:path]}."
                    end
                  end
                end

                ctx[:errors] = errors unless errors.empty?
                errors.empty?
              end
            end
          end
        end
      end
    end
  end
end
