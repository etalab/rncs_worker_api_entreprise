class Representant
  module Contract
    class Create < Reform::Form
      include PopulatorHelper

      property :entreprise_id
      property :denomination
      property :forme_juridique
      property :siren_pm
      property :type_representant
      property :qualite
      property :conjoint_collaborateur_date_fin
      property :id_representant

      property :identite,
        form: Identite::Contract::Create,
        populate_if_empty: Identite,
        skip_if: :skip_identite?

      property :representant_permanent_identite,
        form: Identite::Contract::Create,
        populate_if_empty: RepresentantPermanentIdentite,
        skip_if: :skip_identite?

      property :conjoint_collaborateur_identite,
        form: Identite::Contract::Create,
        populate_if_empty: ConjointCollaborateurIdentite,
        skip_if: :skip_identite?

      property :adresse,
        form: Adresse::Contract::Create,
        populate_if_empty: Adresse,
        skip_if: :skip_adresse?

      property :representant_permanent_adresse,
        form: Adresse::Contract::Create,
        populate_if_empty: RepresentantPermanentAdresse,
        skip_if: :skip_adresse?

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
