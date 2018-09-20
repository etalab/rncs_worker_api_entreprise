class RenameRepresentantConjointCollaborateurFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :representants, :conjoint_collaborateur_nom_patronyme, :conjoint_collab_nom_patronyme
    rename_column :representants, :conjoint_collaborateur_nom_usage, :conjoint_collab_nom_usage
    rename_column :representants, :conjoint_collaborateur_pseudonyme, :conjoint_collab_pseudonyme
    rename_column :representants, :conjoint_collaborateur_prenoms, :conjoint_collab_prenoms
    rename_column :representants, :conjoint_collaborateur_date_fin, :conjoint_collab_date_fin
  end
end
