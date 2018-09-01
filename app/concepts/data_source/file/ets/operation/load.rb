module DataSource
  module File
    module Ets
      module Operation
      class Load < Trailblazer::Operation
          include DataSource::File::Helper

          step ->(ctx, file_path: nil, **) { !file_path.nil? }
          fail ->(ctx, **) { ctx[:errors] = 'No file path given' }, fail_fast: true

          step ->(ctx, file_path:, **) { ::File.exist?(file_path) }
          fail ->(ctx, file_path:, **) { ctx[:errors] = "File '#{file_path}' does not exist." }, fail_fast: true

          step :csv_to_hash
          step Nested(Ets::Operation::Deserialize)
          step Ets::Operation::Store
        end
      end
    end
  end
end
