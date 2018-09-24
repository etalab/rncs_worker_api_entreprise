module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class ResetDatabase
            class << self
              def call(ctx, code_greffe:, **)
                # Be careful to drop rows related to the corresponding greffe only
                code_greffe = code_greffe.to_i.to_s

                Observation
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                Representant
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                Etablissement
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                PersonneMorale
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                PersonnePhysique
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                DossierEntreprise
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                true
                # TODO wrap into a transaction and deal with ActiveRecord errors
              end
            end
          end
        end
      end
    end
  end
end
