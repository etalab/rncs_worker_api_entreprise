class CreateAdresses < ActiveRecord::Migration[5.2]
  def change
    create_table :adresses, id: :uuid do |t|
      t.string :ligne_1
      t.string :ligne_2
      t.string :ligne_3
      t.string :code_postal
      t.string :ville
      t.string :commune
      t.string :pays
      t.string :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
