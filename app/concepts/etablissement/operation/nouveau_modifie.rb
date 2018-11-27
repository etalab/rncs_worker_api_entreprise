class Etablissement
  module Operation
    class NouveauModifie < Trailblazer::Operation
      step :find_dossier_entreprise
      fail :warn_dossier_not_found, Output(:success) => 'End.success'
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

      def warn_dossier_not_found(ctx, data:, **)
        ctx[:warning] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. The etablissement (id_etablissement: #{data[:id_etablissement]}) is not imported."
      end
    end
  end
end
