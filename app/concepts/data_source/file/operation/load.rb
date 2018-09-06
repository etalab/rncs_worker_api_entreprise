module DataSource
  module File
    module Operation
      class Load < Trailblazer::Operation
        step Contract::Validate(constant: DataSource::File::Contract::Load)

        step ->(ctx, params:, **) do
          ctx[:file_name] = params[:file_path].split('/').last.chomp('.csv')
        end

        step ->(ctx, file_name:, **) { ctx[:logger] = Logger.new("log/tc_stock/#{file_name}.log") }

        pass ->(ctx, logger:, **) { logger.info('Start file import...') }
        step Operation::Import
      end
    end
  end
end
