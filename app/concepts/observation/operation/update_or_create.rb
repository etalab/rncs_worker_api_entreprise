class Observation
  module Operation
    class UpdateOrCreate < Trailblazer::Operation
      step :find_dossier_entreprise
      fail :dossier_not_found, Output(:success) => 'End.success'
      step :retrieve_observation
      fail :create_observation, Output(:success) => 'End.success'
      step :update_observation

      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by(
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        )
      end

      def retrieve_observation(ctx, dossier:, data:, **)
        ctx[:observation] = dossier.observations.find_by(id_observation: data[:id_observation])
      end

      def update_observation(_ctx, observation:, data:, **)
        etat_obs = data[:etat]

        if etat_obs == 'Suppression'
          observation.delete
        else
          observation.update(data)
        end
      end

      def create_observation(_ctx, dossier:, data:, **)
        etat_obs = data[:etat]
        dossier.observations.create(data) unless etat_obs == 'Suppression'
        true
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:warning] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The observation with ID: #{data[:id_observation]} is not imported."
      end
    end
  end
end
