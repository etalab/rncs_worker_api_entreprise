module TribunalInstance
  module Stock
    module Unit
      module Operation
        class ResetDatabase < Trailblazer::Operation
          step :reset_database

          def reset_database(ctx, code_greffe:, **)
            [
              "DELETE FROM titmc_actes WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_adresses WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_bilans WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_entreprises WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_etablissements WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_observations WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM titmc_representants WHERE code_greffe = '#{code_greffe}';",
              "DELETE FROM dossiers_entreprises WHERE code_greffe = '#{code_greffe}';"
            ]
              .each do |sql|
              ActiveRecord::Base.connection.execute(sql)
            end

            true
          end
        end
      end
    end
  end
end
