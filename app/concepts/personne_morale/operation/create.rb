class PersonneMorale
  module Operation
    class Create < Trailblazer::Operation
      step :find_dossier_entreprise
      step :save_personne_morale

      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by(
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        )
      end

      def save_personne_morale(ctx, dossier:, data:, **)
        ctx[:created_pm] = dossier.create_personne_morale(data)
      end
    end
  end
end
