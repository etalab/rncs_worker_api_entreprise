class ChangeDossiersEntreprisesDatesToString < ActiveRecord::Migration[5.2]
  def change
    change_column :dossiers_entreprises, :date_immatriculation, :string
    change_column :dossiers_entreprises, :date_premiere_immatriculation, :string
    change_column :dossiers_entreprises, :date_radiation, :string
    change_column :dossiers_entreprises, :date_transfert, :string
    change_column :dossiers_entreprises, :date_debut_activite, :string
    change_column :dossiers_entreprises, :date_debut_premiere_activite, :string
    change_column :dossiers_entreprises, :date_cessation_activite, :string
    change_column :dossiers_entreprises, :date_derniere_modification, :string
  end
end
