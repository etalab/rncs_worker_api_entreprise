class Observation
  module Contract
    class Create < Reform::Form
      property :entreprise_id
      property :numero
      property :date_ajout
      property :date_suppression
      property :texte
      property :etat
      property :id_observation
      property :date_derniere_modification

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
