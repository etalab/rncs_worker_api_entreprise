class UpdateAllDatabaseSchema < ActiveRecord::Migration[5.2]
  # Update database schema to roughly reflect stock files in order to improve
  # import speed and reduce its complexity

  def change
    # Drop tables "adresses" and "identites"
    drop_table :adresses
    drop_table :identites

    # Update "entreprises" table name to "dossiers_entreprises"
    rename_table :entreprises, :dossiers_entreprises

    rename_column :personnes_morales, :entreprise_id, :dossier_entreprise_id
    rename_column :personnes_physiques, :entreprise_id, :dossier_entreprise_id
    rename_column :etablissements, :entreprise_id, :dossier_entreprise_id
    rename_column :representants, :entreprise_id, :dossier_entreprise_id
    rename_column :observations, :entreprise_id, :dossier_entreprise_id

    # Adding columns after dropping "adresses" and "identites" tables
    change_table :personnes_physiques do |t|
      t.string :nom_patronyme
      t.string :nom_usage
      t.string :pseudonyme
      t.string :prenoms
      t.string :date_naissance
      t.string :ville_naissance
      t.string :pays_naissance
      t.string :nationalite
      t.string :conjoint_collab_nom_patronyme
      t.string :conjoint_collab_nom_usage
      t.string :conjoint_collab_pseudonyme
      t.string :conjoint_collab_prenoms
      t.string :adresse_ligne_1
      t.string :adresse_ligne_2
      t.string :adresse_ligne_3
      t.string :adresse_code_postal
      t.string :adresse_ville
      t.string :adresse_code_commune
      t.string :adresse_pays
      t.string :dap_adresse_ligne_1
      t.string :dap_adresse_ligne_2
      t.string :dap_adresse_ligne_3
      t.string :dap_adresse_code_postal
      t.string :dap_adresse_ville
      t.string :dap_adresse_code_commune
      t.string :dap_adresse_pays
    end

    change_table :etablissements do |t|
      t.string :adresse_ligne_1
      t.string :adresse_ligne_2
      t.string :adresse_ligne_3
      t.string :adresse_code_postal
      t.string :adresse_ville
      t.string :adresse_code_commune
      t.string :adresse_pays
    end

    change_table :representants do |t|
      t.string :adresse_ligne_1
      t.string :adresse_ligne_2
      t.string :adresse_ligne_3
      t.string :adresse_code_postal
      t.string :adresse_ville
      t.string :adresse_code_commune
      t.string :adresse_pays
      t.string :representant_permanent_adresse_ligne_1
      t.string :representant_permanent_adresse_ligne_2
      t.string :representant_permanent_adresse_ligne_3
      t.string :representant_permanent_adresse_code_postal
      t.string :representant_permanent_adresse_ville
      t.string :representant_permanent_adresse_code_commune
      t.string :representant_permanent_adresse_pays
      t.string :nom_patronyme
      t.string :nom_usage
      t.string :pseudonyme
      t.string :prenoms
      t.string :date_naissance
      t.string :ville_naissance
      t.string :pays_naissance
      t.string :nationalite
      t.string :representant_permanent_nom_patronyme
      t.string :representant_permanent_nom_usage
      t.string :representant_permanent_pseudonyme
      t.string :representant_permanent_prenoms
      t.string :representant_permanent_date_naissance
      t.string :representant_permanent_ville_naissance
      t.string :representant_permanent_pays_naissance
      t.string :representant_permanent_nationalite
      t.string :conjoint_collaborateur_nom_patronyme
      t.string :conjoint_collaborateur_nom_usage
      t.string :conjoint_collaborateur_pseudonyme
      t.string :conjoint_collaborateur_prenoms
    end
  end
end
