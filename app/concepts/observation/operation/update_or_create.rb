class Observation
  module Operation
    class UpdateOrCreate < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :dossier_not_found, Output(:success) => 'End.success'
      step :retrieve_observation
        fail :create_observation, Output(:success) => 'End.success'
      step :update_observation


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion],
        })
      end

      def retrieve_observation(ctx, dossier:, data:, **)
        ctx[:observation] = dossier.observations.find_by(id_observation: data[:id_observation])
      end

      def update_observation(ctx, observation:, data:, **)
        observation.update_attributes(data)
      end

      def create_observation(ctx, dossier:, data:, **)
        dossier.observations.create(data)
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:warning] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The observation with ID: #{data[:id_observation]} is not imported."
      end
    end
  end
end
