class UpdateDossierEntrepriseForTitmc < ActiveRecord::Migration[5.2]
  def change
    change_table :dossiers_entreprises do |t|
      t.string :numero_rcs
      t.string :code_radiation
      t.string :motif_radiation
    end
  end
end
