class Etablissement
  module Operation
    class Create < Trailblazer::Operation
      step :find_dossier_entreprise
      fail :dossier_not_found, Output(:success) => 'End.success'
      step :save_etablissement


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion],
        })
      end

      def save_etablissement(ctx, dossier:, data:, **)
        ctx[:created_ets] = dossier.etablissements.create(data)
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:warning] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
