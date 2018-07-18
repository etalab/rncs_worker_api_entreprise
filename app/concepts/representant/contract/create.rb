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

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
