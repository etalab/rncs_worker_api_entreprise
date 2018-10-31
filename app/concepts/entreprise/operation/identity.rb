module Entreprise
  module Operation
    class Identity < Trailblazer::Operation
      step :verify_siren
        fail :invalid_siren, fail_fast: true
      step :find_dossiers_entreprise
        fail :no_dossier_exists, fail_fast: true
      step :fetch_dossier_principal
        fail :no_exclusif_dossier_principal, fail_fast: true
      step :fetch_etablissement_principal
        fail :no_etablissement_principal


      def verify_siren(ctx, siren:, **)
        Siren.new(siren).valid?
      end

      def invalid_siren(ctx, **)
        ctx[:http_error] = { code: 422, message: 'Siren invalide' }
      end

      def find_dossiers_entreprise(ctx, siren:, **)
        ctx[:dossiers_entreprise] = DossierEntreprise.where(siren: siren)
        ctx[:dossiers_entreprise].any?
      end

      def no_dossier_exists(ctx, **)
        ctx[:http_error] = { code: 404, message: 'Aucun dossier trouvé.' }
      end

      def fetch_dossier_principal(ctx, dossiers_entreprise:, **)
        dossiers_principaux = dossiers_entreprise.where(type_inscription: 'P')
        if dossiers_principaux.count == 1
          ctx[:dossier_principal] = dossiers_principaux.first
        else
          ctx[:dossiers_principaux_count] = dossiers_principaux.count
          false
        end
      end

      def no_exclusif_dossier_principal(ctx, dossiers_principaux_count:, **)
        ctx[:http_error] = { code: 500, message: "#{dossiers_principaux_count.size} dossiers principaux trouvés" }
      end

      def fetch_etablissement_principal(ctx, dossier_principal:, **)
        ctx[:etablissement_principal] = dossier_principal.etablissement_principal
      end


      def no_etablissement_principal(ctx, **)
        ctx[:http_error] = { code: 500, message: 'Aucun etablissement principal trouvé dans le dossier principal' }
      end
    end
  end
end
