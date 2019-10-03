class DossierEntreprise
  module Operation
    class Create < Trailblazer::Operation
      step :dossier_exists?, Output(:failure) => :create
      step :log_dossier_exists
      step :destroy_existing_dossier
      step :save_new_dossier, id: :create

      def dossier_exists?(ctx, data:, **)
        ctx[:existing_dossier] = DossierEntreprise.find_by(
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        )
      end

      def log_dossier_exists(ctx, existing_dossier:, **)
        ctx[:warning] = "The dossier (code_greffe: #{existing_dossier[:code_greffe]}, numero_gestion: #{existing_dossier[:numero_gestion]}) already exists in database and is overriden."
      end

      def destroy_existing_dossier(_ctx, existing_dossier:, **)
        existing_dossier.destroy
      end

      def save_new_dossier(_ctx, data:, **)
        DossierEntreprise.create(data)
      end
    end
  end
end
