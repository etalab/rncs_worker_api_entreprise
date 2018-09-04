module DataSource
  module File
    module PP
      module Operation
        class BatchImport < Trailblazer::Operation
          step Nested(PP::Operation::Deserialize)
          step PP::Operation::Store
        end
      end
    end
  end
end
