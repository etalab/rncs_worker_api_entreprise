class RenamePersonnePhysiqueConjointCollaborateurDateFin < ActiveRecord::Migration[5.2]
  def change
    rename_column :personnes_physiques, :conjoint_collaborateur_date_fin, :conjoint_collab_date_fin
  end
end
