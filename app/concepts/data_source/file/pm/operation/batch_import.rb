module DataSource
  module File
    module PM
      module Operation
        class BatchImport < Trailblazer::Operation
          step Nested(PM::Operation::Deserialize)
          step PM::Operation::Store
        end
      end
    end
  end
end
