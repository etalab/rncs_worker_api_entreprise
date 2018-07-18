class Etablissement
  module Contract
    class Create < Reform::Form
      property :entreprise_id
      property :type_etablissement
      property :siege_pm
      property :rcs_registre
      property :domiciliataire_nom
      property :domiciliataire_siren
      property :domiciliataire_greffe
      property :domiciliataire_complement
      property :siege_domicile_representant
      property :nom_commercial
      property :enseigne
      property :activite
      property :activite_ambulante
      property :activite_saisonniere
      property :date_debut_activite
      property :origine_fonds
      property :origine_fonds_info
      property :type_exploitation
      property :id_etablissement
      property :date_derniere_modification
      property :libelle_derniere_modification

      validation do
        required(:entreprise_id).filled
      end
    end
  end
end
