module DataSource
  module File
    module Rep
      module Operation
        class Store
          class << self
            def call(ctx, raw_data:, **)
              errors_count = 0
              raw_data.each do |row|
                create_representant = Representant::Operation::Create.call(params: row)

                errors_count += 1 if create_representant.failure?
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
