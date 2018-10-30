class PersonnePhysique
  module Operation
    class Create < Trailblazer::Operation
      step :find_dossier_entreprise
      step :save_personne_physique


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def save_personne_physique(ctx, dossier:, data:, **)
        ctx[:created_pp] = dossier.create_personne_physique(data)
      end
    end
  end
end
