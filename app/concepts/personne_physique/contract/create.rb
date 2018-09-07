class PersonnePhysique
  module Contract
    class Create < Reform::Form
      include PopulatorHelper

      property :activite_forain
      property :dap
      property :dap_denomination
      property :dap_objet
      property :dap_date_cloture
      property :eirl
      property :auto_entrepreneur
      property :conjoint_collaborateur_date_fin

      property :identite,
        form: Identite::Contract::Create,
        populate_if_empty: Identite,
        skip_if: :skip_identite?

      property :conjoint_collaborateur_identite,
        form: Identite::Contract::Create,
        populate_if_empty: ConjointCollaborateurIdentite,
        skip_if: :skip_identite?

      property :adresse,
        form: Adresse::Contract::Create,
        populate_if_empty: Adresse,
        skip_if: :skip_adresse?

      property :dap_adresse,
        form: Adresse::Contract::Create,
        populate_if_empty: DAPAdresse,
        skip_if: :skip_adresse?
    end
  end
end
