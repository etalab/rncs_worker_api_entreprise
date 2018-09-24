module DataSource
  module File
    module Operation
      class Load < Trailblazer::Operation
        step Trailblazer::Operation::Contract::Validate(constant: DataSource::File::Contract::Load)

        pass :rename_csv_headers # two headers 'siren' for the rep csv ...

        step ->(ctx, params:, **) do
          import_file = params[:import_worker].call(file_path: params[:file_path])
        end


        def rename_csv_headers(ctx, params:, **)
          if params[:file_label] == 'rep'
            # for sed portability on different OS : see https://stackoverflow.com/questions/5171901/sed-command-find-and-replace-in-file-and-overwrite-file-doesnt-work-it-empties
            file_path = params[:file_path]
            tmp_file = file_path + '.tmp'
            `sed -e '1s/Nom_Greffe;Numero_Gestion;Siren;Type;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path} > #{tmp_file} && mv #{tmp_file} #{file_path}`
          end
        end
      end
    end
  end
end
