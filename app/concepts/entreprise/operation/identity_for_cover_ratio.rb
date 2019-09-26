# This is for computing the ratio of fiches d'identité only !
# Just removing some database query to improve the time of the task
# as there is no need to fetch the date and verify the siren here
module Entreprise
  module Operation
    class IdentityForCoverRatio < Trailblazer::Operation
      step ->(ctx, **) { ctx[:db_current_date] = Date.today }
      step :fetch_immatriculation_principale
        fail :no_immatriculation_principale, fail_fast: true
      step :fetch_etablissement_principal
        fail :no_etablissement_principal
      step :fetch_identity_data

      def fetch_immatriculation_principale(ctx, siren:, **)
        ctx[:dossier_principal] = DossierEntreprise.immatriculation_principale(siren)
      end

      def no_immatriculation_principale(ctx, siren:, **)
        ctx[:http_error] = { code: 404, message: "Immatriculation principale non trouvée pour le siren #{siren}.", app_code: '1' }
      end

      def fetch_etablissement_principal(ctx, dossier_principal:, **)
        # TODO: this do not warn about multiple etab PRI
        ctx[:etablissement_principal] = dossier_principal.etablissement_principal
      end

      def no_etablissement_principal(ctx, **)
        ctx[:http_error] = { code: 404, message: 'Aucun établissement principal dans le dossier d\'immatriculation.', app_code: '2' }
      end

      def fetch_identity_data(ctx, dossier_principal:, etablissement_principal:, db_current_date:, **)
        data = { dossier_entreprise_greffe_principal: dossier_principal.attributes }
        nested_data = data[:dossier_entreprise_greffe_principal]
        nested_data[:db_current_date] = db_current_date.to_s
        nested_data[:observations]  = dossier_principal.observations.map(&:attributes)
        nested_data[:representants] = dossier_principal.representants.map(&:attributes)
        nested_data[:etablissements] = dossier_principal.etablissements.map(&:attributes)
        nested_data[:etablissement_principal] = etablissement_principal.attributes
        nested_data[:personne_morale] = dossier_principal&.personne_morale&.attributes
        nested_data[:personne_physique] = dossier_principal&.personne_physique&.attributes
        ctx[:entreprise_identity] = data.deep_symbolize_keys!
      end
    end
  end
end
