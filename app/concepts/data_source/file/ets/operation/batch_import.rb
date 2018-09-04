module DataSource
  module File
    module Ets
      module Operation
        class BatchImport < Trailblazer::Operation
          step Nested(Ets::Operation::Deserialize)
          step Ets::Operation::Store
        end
      end
    end
  end
end
