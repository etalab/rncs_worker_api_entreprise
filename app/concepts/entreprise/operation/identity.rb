module Entreprise
  module Operation
    class Identity < Trailblazer::Operation
      step Nested(TribunalCommerce::DailyUpdate::Operation::DBCurrentDate), Output(:fail_fast) => Track(:failure)
      fail :empty_database, fail_fast: true
      step :verify_siren
      fail :invalid_siren, fail_fast: true
      step :fetch_immatriculation_principale
      fail :no_immatriculation_principale, fail_fast: true
      step :fetch_etablissement_principal
      fail :no_etablissement_principal
      step :fetch_identity_data

      def verify_siren(_, siren:, **)
        Siren.new(siren).valid?
      end

      def invalid_siren(ctx, **)
        ctx[:http_error] = { code: 422, message: 'Le numéro siren en paramètre est mal formaté.' }
      end

      def fetch_immatriculation_principale(ctx, siren:, **)
        ctx[:dossier_principal] = DossierEntreprise.immatriculation_principale(siren)
      end

      def no_immatriculation_principale(ctx, siren:, **)
        ctx[:http_error] = { code: 404, message: "Immatriculation principale non trouvée pour le siren #{siren}." }
      end

      def fetch_etablissement_principal(ctx, dossier_principal:, **)
        # TODO: this do not warn about multiple etab PRI
        ctx[:etablissement_principal] = dossier_principal.etablissement_principal
      end

      def no_etablissement_principal(ctx, **)
        ctx[:http_error] = { code: 404, message: 'Aucun établissement principal dans le dossier d\'immatriculation.' }
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

      def empty_database(ctx, **)
        ctx[:http_error] = {
          code: 501,
          message: 'Nothing load into the database yet: please import the last stock available.'
        }
      end
    end
  end
end
