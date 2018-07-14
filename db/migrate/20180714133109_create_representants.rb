class CreateRepresentants < ActiveRecord::Migration[5.2]
  def change
    create_table :representants, id: :uuid do |t|
      t.string :denomination
      t.string :forme_juridique
      t.string :siren
      t.string :type
      t.string :qualite
      t.string :conjoint_collaborateur_date_fin
      t.string :id_representant
      t.string :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
