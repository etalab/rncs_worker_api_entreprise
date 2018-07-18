class RenameAdressesCommune < ActiveRecord::Migration[5.2]
  def change
    rename_column :adresses, :commune, :code_commune
  end
end
