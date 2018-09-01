module DataSource
  module File
    module PM
      module Operation
        class Store
          class << self
            def call(ctx, raw_data:, **)
              errors_count = 0
              raw_data.each do |row|
                create_entreprise_with_pm = Entreprise::Operation::CreateWithPM.call(params: row)

                errors_count += 1 if create_entreprise_with_pm.failure?
                # TODO deal with errors when form validations are setup
              end

              ctx[:import_errors_count] = errors_count
              errors_count == 0
            end
          end
        end
      end
    end
  end
end
