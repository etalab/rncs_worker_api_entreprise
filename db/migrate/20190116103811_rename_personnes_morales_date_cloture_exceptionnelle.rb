class RenamePersonnesMoralesDateClotureExceptionnelle < ActiveRecord::Migration[5.2]
  def change
   rename_column :personnes_morales, :date_cloture_exeptionnelle, :date_cloture_exceptionnelle
  end
end
