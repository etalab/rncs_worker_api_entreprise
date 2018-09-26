module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class ResetDatabase
            class << self
              def call(ctx, code_greffe:, **)
                # Be careful to drop rows related to the corresponding greffe only

                [
                  "DELETE FROM dossiers_entreprises WHERE code_greffe = '#{code_greffe}';",
                  "DELETE FROM personnes_morales WHERE code_greffe = '#{code_greffe}';",
                  "DELETE FROM personnes_physiques WHERE code_greffe = '#{code_greffe}';",
                  "DELETE FROM representants WHERE code_greffe = '#{code_greffe}';",
                  "DELETE FROM etablissements WHERE code_greffe = '#{code_greffe}';",
                  "DELETE FROM observations WHERE code_greffe = '#{code_greffe}';",
                ]
                  .each do |sql|
                  ActiveRecord::Base.connection.execute(sql)
                end

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
