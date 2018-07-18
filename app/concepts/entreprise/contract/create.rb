class Entreprise
  module Contract
    class Create < Reform::Form
      property :code_greffe
      property :nom_greffe
      property :numero_gestion
      property :siren
      property :type_inscription
      property :date_immatriculation
      property :date_premiere_immatriculation
      property :date_radiation
      property :date_transfert
      property :sans_activite
      property :date_debut_activite
      property :date_debut_premiere_activite
      property :date_cessation_activite
      property :date_derniere_modification
      property :libelle_derniere_modification
    end
  end
end
