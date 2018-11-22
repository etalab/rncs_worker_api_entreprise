class DossierEntreprise
  module Operation
    class Update < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :find_dossier_with_same_siren,
          Output(:success) => Track(:num_gestion_change),
          Output(:failure) => Track(:new_dossier)

        step :create_new_dossier, magnetic_to: [:new_dossier], Output(:success) => Track(:new_dossier)
        step :warn_new_dossier, magnetic_to: [:new_dossier], Output(:success) => 'End.success'

      step :warn_num_gestion_change, magnetic_to: [:num_gestion_change], Output(:success) => :update
      step :update, id: :update


      def find_dossier_entreprise(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion]
        })
      end

      def update(ctx, dossier:, data:, **)
        dossier.update_attributes(data)
      end

      def find_dossier_with_same_siren(ctx, data:, **)
        ctx[:dossier] = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          siren: data[:siren]
        })
      end

      def create_new_dossier(ctx, data:, **)
        DossierEntreprise.create(data)
      end

      def warn_new_dossier(ctx, data:, **)
        ctx[:warning] = "Dossier (numero_gestion: #{data[:numero_gestion]}) not found and no dossier with the siren number #{data[:siren]} exist for greffe #{data[:code_greffe]}. Creating new dossier."
      end

      def warn_num_gestion_change(ctx, dossier:, data:, **)
        ctx[:warning] = "Dossier (numero_gestion: #{data[:numero_gestion]}) not found for greffe #{data[:code_greffe]}, but an existing dossier (numero_gestion: #{dossier.numero_gestion}) is found for siren #{data[:siren]} : updating this dossier instead."
      end
    end
  end
end
