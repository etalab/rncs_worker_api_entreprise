class ChangeTitmcEntreprise < ActiveRecord::Migration[5.2]
  def change
    rename_column :titmc_entreprises, :status_edition_extrait, :statut_edition_extrait
    rename_column :titmc_representants, :lieu_naissance, :ville_naissance
  end
end
