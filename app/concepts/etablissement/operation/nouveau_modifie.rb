class Etablissement
  module Operation
    class NouveauModifie < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :dossier_not_found, fail_fast: true
      step :retrieve_etablissement
        fail :create_new_etablissement
        fail :warning_message, Output(:success) => 'End.success'
      step :update


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def retrieve_etablissement(ctx, dossier:, data:, **)
        ctx[:etablissement] = dossier.etablissements.find_by(id_etablissement: data[:id_etablissement])
      end

      def update(ctx, etablissement:, data:, **)
        etablissement.update_attributes(data)
      end

      def create_new_etablissement(ctx, dossier:, data:, **)
        dossier.etablissements.create(data)
      end

      def warning_message(ctx, data:, **)
        ctx[:warning] = "The etablissement (id_etablissement: #{data[:id_etablissement]}) was not found in dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) for update. Created instead."
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:error] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
