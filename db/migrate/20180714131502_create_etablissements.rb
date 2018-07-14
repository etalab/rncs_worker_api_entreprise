class CreateEtablissements < ActiveRecord::Migration[5.2]
  def change
    create_table :etablissements, id: :uuid do |t|
      t.string :type
      t.string :siege_pm
      t.string :rcs_registre
      t.string :domiciliataire_nom
      t.string :domiciliataire_siren
      t.string :domiciliataire_greffe
      t.string :domiciliataire_complement
      t.string :siege_domicile_representant
      t.string :nom_commercial
      t.string :enseigne
      t.string :activite_ambulante
      t.string :activite_saisonniere
      t.string :activite_non_sedentaire
      t.string :date_debut_activite
      t.string :activite
      t.string :origine_fonds
      t.string :origine_fonds_info
      t.string :type_exploitation
      t.string :id_etablissement
      t.string :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
