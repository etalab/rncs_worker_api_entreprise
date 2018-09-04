module DataSource
  module File
    module Ets
      module Operation
        class Store
          class << self
            def call(ctx, raw_data:, siren_in_db:, **)
              errors_count = 0
              validated_models = []
              raw_data.each do |row|
                build_etablissement = Etablissement::Operation::Create.call(params: row, siren_in_db: siren_in_db)

                if build_etablissement.success?
                  validated_models.push(build_etablissement[:model])
                else
                  errors_count += 1
                  # TODO deal with errors when form validations are setup
                end
              end

              Etablissement.import validated_models, recursive: true
              ctx[:import_errors_count] = errors_count
              errors_count == 0
            end
          end
        end
      end
    end
  end
end
