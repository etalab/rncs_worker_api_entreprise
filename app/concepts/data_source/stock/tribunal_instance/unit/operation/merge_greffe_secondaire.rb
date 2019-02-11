module DataSource
  module Stock
    module TribunalInstance
      module Unit
        module Operation
          class MergeGreffeSecondaire < Trailblazer::Operation
            step :merge_etablissements
            step :merge_representants
            step :merge_actes
            step :merge_bilans
            step :merge_observations

            def merge_etablissements(ctx, entreprise_secondaire:, entreprise_principale:, code_greffe:, **)
              entreprise_secondaire.etablissements.each do |e|
                e.code_greffe = code_greffe
                e.adresse&.code_greffe = code_greffe
              end

              entreprise_principale.etablissements << entreprise_secondaire.etablissements
            end

            def merge_representants(ctx, entreprise_secondaire:, entreprise_principale:, code_greffe:, **)
              entreprise_secondaire.representants.each do |r|
                r.code_greffe = code_greffe
                r.adresse_representant_permanent&.code_greffe = code_greffe
                r.adresse_representant&.code_greffe = code_greffe
              end

              entreprise_principale.representants << entreprise_secondaire.representants
            end

            def merge_actes(ctx, entreprise_secondaire:, entreprise_principale:, code_greffe:, **)
              entreprise_secondaire.actes.each { |a| a.code_greffe = code_greffe }
              entreprise_principale.actes << entreprise_secondaire.actes
            end

            def merge_bilans(ctx, entreprise_secondaire:, entreprise_principale:, code_greffe:, **)
              entreprise_secondaire.bilans.each { |b| b.code_greffe = code_greffe }
              entreprise_principale.bilans << entreprise_secondaire.bilans
            end

            def merge_observations(ctx, entreprise_secondaire:, entreprise_principale:, code_greffe:, **)
              entreprise_secondaire.observations.each { |o| o.code_greffe = code_greffe }
              entreprise_principale.observations << entreprise_secondaire.observations
            end
          end
        end
      end
    end
  end
end
