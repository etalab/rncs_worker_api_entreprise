class CreateTitmcEtablissements < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_etablissements, id: :uuid do |t|
      t.string 'type_etablissement'
      t.string 'siret'
      t.string 'activite'
      t.string 'code_activite'
      t.string 'enseigne'
      t.string 'nom_commercial'
      t.string 'date_debut_activite'
      t.string 'origine_fonds'
      t.string 'type_activite'
      t.string 'date_cessation_activite'
      t.string 'type_exploitation'
      t.string 'precedent_exploitant_nom'
      t.string 'precedent_exploitant_nom_usage'
      t.string 'precedent_exploitant_prenom'
      t.string 'entreprise_id'

      t.timestamps
    end
  end
end
