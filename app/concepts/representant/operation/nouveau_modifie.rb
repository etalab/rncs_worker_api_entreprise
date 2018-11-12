class Representant
  module Operation
    class NouveauModifie < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :dossier_not_found, fail_fast: true
      step :retrieve_representant
        fail :create_new_representant
        fail :warning_message, Output(:success) => 'End.success'
      step :update


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def retrieve_representant(ctx, dossier:, data:, **)
        ctx[:representant] = dossier.representants.find_by(
          id_representant: data[:id_representant],
          qualite: data[:qualite]
        )
      end

      def update(ctx, representant:, data:, **)
        representant.update_attributes(data)
      end

      def create_new_representant(ctx, dossier:, data:, **)
        dossier.representants.create(data)
      end

      def warning_message(ctx, data:, **)
        ctx[:warning] = "The representant (id_representant: #{data[:id_representant]}, qualite: #{data[:qualite]}) was not found in dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}). Representant created instead."
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:error] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
