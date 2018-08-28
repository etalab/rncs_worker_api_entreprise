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
                  file_loader = file[:loader]

                  unless file_loader.nil? # TODO remove when all file loader are implemented
                    import = file_loader.call(file_path: file[:path])

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
