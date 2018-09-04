module DataSource
  module File
    module Obs
      module Operation
        class Store
          class << self
            def call(ctx, raw_data:, **)
              errors_count = 0
              validated_models = []
              raw_data.each do |row|
                build_observation = Observation::Operation::Create.call(params: row)

                if build_observation.success?
                  validated_models.push(build_observation[:model])
                else
                  errors_count += 1
                  # TODO deal with errors when form validations are setup
                end
              end

              Observation.import validated_models, recursive: true
              ctx[:import_errors_count] = errors_count
              errors_count == 0
            end
          end
        end
      end
    end
  end
end
