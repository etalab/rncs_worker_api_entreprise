module DataSource
  module File
    module Operation
      class BatchImport < Trailblazer::Operation
        step Nested(PM::Operation::Deserialize)
        step PM::Operation::Store
      end
    end
  end
end
