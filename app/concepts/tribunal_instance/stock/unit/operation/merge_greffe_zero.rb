module TribunalInstance
  module Stock
    module Unit
      module Operation
        class MergeGreffeZero < Trailblazer::Operation
          # Cf README section 'code greffe 0000' to know why we are doing this

          step :merge_etablissements
          step :merge_representants
          step :merge_observations

          def merge_etablissements(_, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.etablissements.each do |e|
              e.code_greffe = code_greffe
              e.adresse&.code_greffe = code_greffe
            end

            entreprise_related.etablissements << entreprise_code_greffe_0000.etablissements
          end

          def merge_representants(_, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.representants.each do |r|
              r.code_greffe = code_greffe
              r.adresse_representant_permanent&.code_greffe = code_greffe
              r.adresse_representant&.code_greffe = code_greffe
            end

            entreprise_related.representants << entreprise_code_greffe_0000.representants
          end

          def merge_observations(_, entreprise_code_greffe_0000:, entreprise_related:, code_greffe:, **)
            entreprise_code_greffe_0000.observations.each { |o| o.code_greffe = code_greffe }
            entreprise_related.observations << entreprise_code_greffe_0000.observations
          end
        end
      end
    end
  end
end
