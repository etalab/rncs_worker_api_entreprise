module DataSource
  module File
    module Rep
      module Operation
        class BatchImport < Trailblazer::Operation
          step Nested(Rep::Operation::Deserialize)
          step Rep::Operation::Store
        end
      end
    end
  end
end
