class RenameEtablissementsType < ActiveRecord::Migration[5.2]
  def change
    rename_column :etablissements, :type, :type_etablissement
  end
end
