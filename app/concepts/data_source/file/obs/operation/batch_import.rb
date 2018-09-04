module DataSource
  module File
    module Obs
      module Operation
        class BatchImport < Trailblazer::Operation
          step Nested(Obs::Operation::Deserialize)
          step Obs::Operation::Store
        end
      end
    end
  end
end
