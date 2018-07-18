class PersonnePhysique
  module Contract
    class Create < Reform::Form
      property :entreprise_id
      property :activite_forain
      property :dap
      property :dap_denomination
      property :dap_objet
      property :dap_date_cloture
      property :eirl
      property :auto_entrepreneur
      property :conjoint_collaborateur_date_fin

      property :identite, form: Identite::Contract::Create, populate_if_empty: Identite
      property :conjoint_collaborateur_identite, form: Identite::Contract::Create, populate_if_empty: ConjointCollaborateurIdentite

      property :adresse, form: Adresse::Contract::Create, populate_if_empty: Adresse
      property :dap_adresse, form: Adresse::Contract::Create, populate_if_empty: DAPAdresse

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
