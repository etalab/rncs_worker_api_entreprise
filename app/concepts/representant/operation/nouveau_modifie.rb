class Representant
  module Operation
    class NouveauModifie < Trailblazer::Operation
      step :find_dossier_entreprise
      fail :warn_dossier_not_found, Output(:success) => End(:success)
      step :retrieve_representant
        fail :create_new_representant
        fail :warning_message, Output(:success) => End(:success)
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
        representant.update(data)
      end

      def create_new_representant(ctx, dossier:, data:, **)
        dossier.representants.create(data)
      end

      def warning_message(ctx, data:, **)
        ctx[:warning] = "The representant (id_representant: #{data[:id_representant]}, qualite: #{data[:qualite]}) was not found in dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}). Representant created instead."
      end

      def warn_dossier_not_found(ctx, data:, **)
        ctx[:warning] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The representant (id_representant: #{data[:id_representant]}, qualite: #{data[:qualite]}) is not imported."
      end
    end
  end
end
