class CreatePersonnesPhysiques < ActiveRecord::Migration[5.2]
  def change
    create_table :personnes_physiques, id: :uuid do |t|
      t.string :activite_forain
      t.string :dap
      t.string :dap_denomination
      t.string :dap_objet
      t.string :dap_date_cloture
      t.string :eirl
      t.string :auto_entrepreneur
      t.date :conjoint_collaborateur_date_fin
      t.date :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
