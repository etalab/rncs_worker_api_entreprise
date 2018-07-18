class RenameDossiersEntreprisesToEntreprises < ActiveRecord::Migration[5.2]
  def change
    remove_index :dossiers_entreprises, :numero_gestion
    rename_table :dossiers_entreprises, :entreprises
    add_index :entreprises, :numero_gestion

    rename_column :personnes_morales, :dossier_entreprise_id, :entreprise_id
  end
end
