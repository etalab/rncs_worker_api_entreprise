class DossierEntreprise
  module Operation
    class Supersede < Trailblazer::Operation
      step :find_existing_dossier, Output(:failure) => Id(:save_new_dossier)
      step :destroy_old_dossier
      step :save_new_dossier


      def find_existing_dossier(ctx, data:, **)
        ctx[:old_dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def destroy_old_dossier(ctx, old_dossier:, **)
        old_dossier.destroy
      end

      def save_new_dossier(ctx, data:, **)
        DossierEntreprise.create(data)
      end
    end
  end
end
