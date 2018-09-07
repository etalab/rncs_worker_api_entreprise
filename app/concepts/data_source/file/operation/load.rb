module DataSource
  module File
    module Operation
      class Load < Trailblazer::Operation
        step Trailblazer::Operation::Contract::Validate(constant: DataSource::File::Contract::Load)

        step ->(ctx, params:, **) do
          ctx[:file_name] = params[:file_path].split('/').last.chomp('.csv')
        end

        step ->(ctx, file_name:, **) { ctx[:logger] = Logger.new("log/tc_stock/#{file_name}.log") }

        pass :rename_csv_headers # two headers 'siren' for the rep csv ...
        pass ->(ctx, logger:, **) { logger.info('Start file import...') }
        step Operation::Import


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
