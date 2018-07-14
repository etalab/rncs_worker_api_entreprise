class CreateIdentite < ActiveRecord::Migration[5.2]
  def change
    create_table :identites, id: :uuid do |t|
      t.string :nom_patronyme
      t.string :nom_usage
      t.string :pseudonyme
      t.string :prenoms
      t.string :date_naissance
      t.string :ville_naissance
      t.string :pays_naissance
      t.string :nationalite
      t.string :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
