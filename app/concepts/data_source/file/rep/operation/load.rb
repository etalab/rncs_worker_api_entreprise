module DataSource
  module File
    module Rep
      module Operation
        class Load < Trailblazer::Operation
          include DataSource::File::Helper

          step ->(ctx, file_path: nil, **) { !file_path.nil? }
          fail ->(ctx, **) { ctx[:errors] = 'No file path given' }, fail_fast: true

          step ->(ctx, file_path:, **) { ::File.exist?(file_path) }
          fail ->(ctx, file_path:, **) { ctx[:errors] = "File '#{file_path}' does not exist." }, fail_fast: true

          step :rename_csv_headers # two headers 'siren' for the same csv ...
          step :csv_to_hash
          step Nested(Rep::Operation::Deserialize)
          step Rep::Operation::Store


          def rename_csv_headers(ctx, file_path:, **)
            # for sed portability on different OS : see https://stackoverflow.com/questions/5171901/sed-command-find-and-replace-in-file-and-overwrite-file-doesnt-work-it-empties
            tmp_file = file_path + '.tmp'
            `sed -e '1s/Nom_Greffe;Numero_Gestion;Siren;Type;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path} > #{tmp_file} && mv #{tmp_file} #{file_path}`
          end
        end
      end
    end
  end
end
