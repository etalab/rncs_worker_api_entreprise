module DataSource
  module File
    module PM
      module Operation
        class Load < Trailblazer::Operation
          include DataSource::File::Helper

          step ->(ctx, file_path: nil, **) { !file_path.nil? }
          fail ->(ctx, **) { ctx[:errors] = 'No file path given' }, fail_fast: true

          step ->(ctx, file_path:, **) { ::File.exist?(file_path) }
          fail ->(ctx, file_path:, **) { ctx[:errors] = "File '#{file_path}' does not exist." }, fail_fast: true

          step :csv_to_hash
          step Nested(PM::Operation::Deserialize)
          step :insert_into_database

          def insert_into_database(ctx, raw_data:, **)
            import_errors = 0
            raw_data.each do |row|
              create_entreprise_with_pm = Entreprise::Operation::CreateWithPM.call(params: row)

              import_errors += 1 if create_entreprise_with_pm.failure?
            end

            ctx[:import_errors] = import_errors
            import_errors < raw_data.count
          end
        end
      end
    end
  end
end
