class RenameRepresentantsAttributes < ActiveRecord::Migration[5.2]
  def change
    rename_column :representants, :siren, :siren_pm
    rename_column :representants, :type, :type_representant
  end
end
