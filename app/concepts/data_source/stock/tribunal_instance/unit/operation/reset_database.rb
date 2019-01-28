module DataSource
  module Stock
    module TribunalInstance
      module Unit
        module Operation
          class ResetDatabase < Trailblazer::Operation
            step :reset_database

              def reset_database(ctx, code_greffe:, **)
                DossierEntreprise
                  .where(code_greffe: code_greffe)
                  .destroy_all
            end
          end
        end
      end
    end
  end
end
