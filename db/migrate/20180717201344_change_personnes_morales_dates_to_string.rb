class ChangePersonnesMoralesDatesToString < ActiveRecord::Migration[5.2]
  def change
    change_column :personnes_morales, :capital, :string
    change_column :personnes_morales, :capital_actuel, :string
    change_column :personnes_morales, :date_cloture_exeptionnelle, :string
    change_column :personnes_morales, :duree_pm, :string
    change_column :personnes_morales, :date_derniere_modification, :string
  end
end
