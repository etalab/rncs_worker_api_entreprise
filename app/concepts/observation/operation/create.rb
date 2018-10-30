class Observation
  module Operation
    class Create < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :dossier_not_found
      step :save_observation


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion],
        })
      end

      def save_observation(ctx, dossier:, data:, **)
        ctx[:created_obs] = dossier.observations.create(data)
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:error] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
