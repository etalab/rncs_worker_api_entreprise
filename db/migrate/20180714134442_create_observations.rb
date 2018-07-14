class CreateObservations < ActiveRecord::Migration[5.2]
  def change
    create_table :observations, id: :uuid do |t|
      t.string :id_observation
      t.string :numero
      t.string :date_ajout
      t.string :date_suppression
      t.text   :texte
      t.string :etat
      t.string :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
