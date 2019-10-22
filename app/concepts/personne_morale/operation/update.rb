class PersonneMorale
  module Operation
    class Update < Trailblazer::Operation
      step :find_dossier_entreprise
      fail :dossier_not_found, fail_fast: true
      step :personne_morale_exists?
      fail :create, Output(:success) => 'End.success'
      step :update

      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by(
          code_greffe:    data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        )
      end

      def personne_morale_exists?(_, dossier:, **)
        !dossier.personne_morale.nil?
      end

      def update(_, dossier:, data:, **)
        dossier.personne_morale.update(data)
      end

      def create(_, dossier:, data:, **)
        dossier.create_personne_morale(data)
      end

      def dossier_not_found(ctx, data:, **)
        ctx[:error] = "The dossier (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}) is not found. Aborting..."
      end
    end
  end
end
