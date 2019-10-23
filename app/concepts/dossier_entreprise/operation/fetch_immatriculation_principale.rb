class DossierEntreprise
  module Operation
    class FetchImmatriculationPrincipale < Trailblazer::Operation
      step :any_immatriculations_principales?
      failure :any_immatriculations_secondaires?, Output(:success) => Track(:immatriculation_secondaire)
      failure :log_not_registered_to_rncs, Output(:failure) => 'End.failure'

      step :uniq?, Output(:success) => 'End.success'
      failure :none_date_immatriculation_nil?, Output(:success) => Track(:success)
      failure :log_failed_to_find_valid_immatriculation, Output(:failure) => 'End.failure'
      step :choose_latest_immatriculation_principale

      failure :log_registered_but_no_immatriculation_principale_found, magnetic_to: [:immatriculation_secondaire]

      def any_immatriculations_principales?(ctx, siren:, **)
        ctx[:dossiers] = DossierEntreprise.where(siren: siren, type_inscription: 'P')
        ctx[:dossiers].any?
      end

      def any_immatriculations_secondaires?(ctx, siren:, **)
        ctx[:dossiers] = DossierEntreprise.where(siren: siren, type_inscription: 'S')
        ctx[:dossiers].any?
      end

      def uniq?(ctx, dossiers:, **)
        ctx[:dossier_principal] = dossiers.first if dossiers.size == 1
      end

      def none_date_immatriculation_nil?(_, dossiers:, **)
        dossiers.none? { |immat| immat.date_immatriculation.nil? }
      end

      def choose_latest_immatriculation_principale(ctx, dossiers:, **)
        ctx[:dossier_principal] = dossiers.max_by { |immat| Date.parse(immat.date_immatriculation) }
      end

      def log_failed_to_find_valid_immatriculation(ctx, siren:, **)
        ctx[:error] = "Impossible de constituer la fiche pour le SIREN #{siren}."
      end

      def log_not_registered_to_rncs(ctx, siren:, **)
        ctx[:error] = "Le SIREN #{siren} n'est pas inscrit au RNCS."
      end

      def log_registered_but_no_immatriculation_principale_found(ctx, siren:,**)
        ctx[:error] = "Immatriculation principale non trouvée pour le siren #{siren}."
      end
    end
  end
end
