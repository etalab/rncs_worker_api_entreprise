module TribunalInstance
  module Stock
    module Unit
      module Operation
        class MergeGreffeZero < Trailblazer::Operation
          # Cf README section 'code greffe 0000' to know why we are doing this

          step :merge_etablissements
          step :merge_representants
          step :merge_actes
          step :merge_bilans
          step :merge_observations

          def merge_etablissements(ctx, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.etablissements.each do |e|
              e.code_greffe = code_greffe
              e.adresse&.code_greffe = code_greffe
            end

            entreprise_related.etablissements << entreprise_code_greffe_0000.etablissements
          end

          def merge_representants(ctx, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.representants.each do |r|
              r.code_greffe = code_greffe
              r.adresse_representant_permanent&.code_greffe = code_greffe
              r.adresse_representant&.code_greffe = code_greffe
            end

            entreprise_related.representants << entreprise_code_greffe_0000.representants
          end

          def merge_actes(ctx, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.actes.each { |a| a.code_greffe = code_greffe }
            entreprise_related.actes << entreprise_code_greffe_0000.actes
          end

          def merge_bilans(ctx, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.bilans.each { |b| b.code_greffe = code_greffe }
            entreprise_related.bilans << entreprise_code_greffe_0000.bilans
          end

          def merge_observations(ctx, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.observations.each { |o| o.code_greffe = code_greffe }
            entreprise_related.observations << entreprise_code_greffe_0000.observations
          end
        end
      end
    end
  end
end
