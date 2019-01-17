module DataSource
  module Stock
    module TribunalInstance
      module Unit
        module Operation
          class Import < Trailblazer::Operation
            step :empty

            def empty(ctx, **)
              true
            end
          end
        end
      end
    end
  end
end
