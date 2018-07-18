class ChangePersonnesPhysiquesDatesToString < ActiveRecord::Migration[5.2]
  def change
    change_column :personnes_physiques, :conjoint_collaborateur_date_fin, :string
    change_column :personnes_physiques, :date_derniere_modification, :string
  end
end
