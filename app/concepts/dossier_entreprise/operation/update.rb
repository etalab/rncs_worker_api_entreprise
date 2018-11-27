class DossierEntreprise
  module Operation
    class Update < Trailblazer::Operation
      step :find_dossier_entreprise
        fail :find_dossier_with_same_siren, Output(:success) => :create
      step :update, Output(:success) => 'End.success'

      # TODO failing without Output(:success) => 'End.success'
      step :create, id: :create, Output(:success) => 'End.success'


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
        dossier = DossierEntreprise.find_by({
          code_greffe: data[:code_greffe],
          siren: data[:siren]
        })

        if !dossier.nil?
          ctx[:warning] = "Dossier (numero_gestion: #{data[:numero_gestion]}) not found for greffe #{data[:code_greffe]}, but an existing dossier (numero_gestion: #{dossier.numero_gestion}) is found for siren #{data[:siren]} : a new dossier is created besides the existing one."

        else
          ctx[:warning] = "Dossier (numero_gestion: #{data[:numero_gestion]}) not found and no dossier with the siren number #{data[:siren]} exist for greffe #{data[:code_greffe]}. Creating new dossier."
        end
        true
      end

      def create(ctx, data:, **)
        DossierEntreprise.create(data)
      end
    end
  end
end
