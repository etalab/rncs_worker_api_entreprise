module DataSource
  module File
    module PM
      module Operation
        class Load < Trailblazer::Operation
          include DataSource::File::Helper

          step ->(ctx, file_path: nil, **) { !file_path.nil? }
          fail ->(ctx, **) { ctx[:errors] = 'No file path given' }, fail_fast: true

          step ->(ctx, file_path:, **) { ::File.exist?(file_path) }
          fail ->(ctx, file_path:, **) { ctx[:errors] = "File '#{file_path}' does not exist." }

          step :csv_to_hash
          step Nested(PM::Operation::Deserialize)
          step :insert_into_database

          def insert_into_database(ctx, raw_data:, **)
            raw_data.each do |row|
              create_entreprise = Entreprise::Operation::Create.call(params: row)
              if create_entreprise.success?
                row[:entreprise_id] = create_entreprise[:model].id
                create_personne_morale = PersonneMorale::Operation::Create.call(params: row)
              end
            end
          end
        end
      end
    end
  end
end
