class PersonneMorale
  module Contract
    class Create < Reform::Form
      property :entreprise_id
      property :denomination
      property :sigle
      property :forme_juridique
      property :associe_unique
      property :activite_principale
      property :type_capital
      property :capital
      property :capital_actuel
      property :devise
      property :date_cloture
      property :date_cloture_exeptionnelle
      property :economie_sociale_solidaire
      property :duree_pm
      property :date_derniere_modification
      property :libelle_derniere_modification

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
