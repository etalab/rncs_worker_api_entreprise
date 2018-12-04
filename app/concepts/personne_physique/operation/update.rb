class PersonnePhysique
  module Operation
    class Update < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :dossier_not_found, fail_fast: true
      step :personne_physique_exists?
        fail :create, Output(:success) => 'End.success'
      step :update


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def personne_physique_exists?(ctx, dossier:, **)
        !dossier.personne_physique.nil?
      end

      def update(ctx, dossier:, data:, **)
        dossier.personne_physique.update_attributes(data)
      end

      def create(ctx, dossier:, data:, **)
        dossier.create_personne_physique(data)
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:error] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
