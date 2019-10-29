class DossierEntreprise
  module Operation
    class FetchImmatriculationPrincipale < Trailblazer::Operation
      step :any_immatriculation?
      failure :log_no_rncs_immatriculation, Output(:success) => 'End.failure'
      step :any_immatriculation_principale?
      failure :log_immat_secondaire_only, Output(:success) => 'End.failure'
      step :possible_to_identify_immat_principale?
      failure :log_cannot_identify_latest_immat, Output(:success) => 'End.failure'
      step :return_only_or_latest_immat_principale

      def any_immatriculation?(ctx, siren:, **)
        ctx[:dossiers] = DossierEntreprise.where(siren: siren)
        ctx[:dossiers].any?
      end

      def any_immatriculation_principale?(ctx, dossiers:, **)
        ctx[:immat_principales] = dossiers.select { |d| d.type_inscription == 'P' }
        ctx[:immat_principales].any?
      end

      def possible_to_identify_immat_principale?(_, immat_principales:, **)
        one_immat_only = immat_principales.count == 1
        all_date_immat_filled = immat_principales.all? { |d| !d.date_immatriculation.nil? }
        one_immat_only || all_date_immat_filled
      end

      def return_only_or_latest_immat_principale(ctx, immat_principales:, **)
        ctx[:dossier_principal] = immat_principales.max_by { |immat| Date.parse(immat.date_immatriculation) }
      end

      def log_no_rncs_immatriculation(ctx, siren:, **)
        ctx[:error] = "Aucune immatriculation trouvée pour le siren #{siren}"
      end

      def log_immat_secondaire_only(ctx, siren:,**)
        ctx[:error] = "Immatriculation principale non trouvée pour le siren #{siren}."
      end

      def log_cannot_identify_latest_immat(ctx, siren:, **)
        ctx[:error] = "Impossible de constituer la fiche pour le SIREN #{siren}."
      end
    end
  end
end
