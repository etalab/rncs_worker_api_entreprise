module DataSource
  module File
    module PM
      module Operation
        class Load < Trailblazer::Operation
          step ->(ctx, name:, **) { ctx[:logger] = Logger.new("log/tc_stock/#{name}.log") }

          # TODO move validations into a contract
          step ->(ctx, file_path: nil, **) { !file_path.nil? }
          fail ->(ctx, **) { ctx[:errors] = 'No file path given' }, fail_fast: true

          step ->(ctx, file_path:, **) { ::File.exist?(file_path) }
          fail ->(ctx, file_path:, **) { ctx[:errors] = "File '#{file_path}' does not exist." }, fail_fast: true

          step PM::Operation::Import
        end
      end
    end
  end
end
