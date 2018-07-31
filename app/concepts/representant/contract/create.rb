class Representant
  module Contract
    class Create < Reform::Form
      property :entreprise_id
      property :denomination
      property :forme_juridique
      property :siren_pm
      property :type_representant
      property :qualite
      property :conjoint_collaborateur_date_fin
      property :id_representant

      property :identite, form: Identite::Contract::Create, populate_if_empty: Identite
      property :representant_permanent_identite, form: Identite::Contract::Create, populate_if_empty: RepresentantPermanentIdentite
      property :conjoint_collaborateur_identite, form: Identite::Contract::Create, populate_if_empty: ConjointCollaborateurIdentite

      property :adresse, form: Adresse::Contract::Create, populate_if_empty: Adresse
      property :representant_permanent_adresse, form: Adresse::Contract::Create, populate_if_empty: RepresentantPermanentAdresse

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
