class CreatePersonnesMorales < ActiveRecord::Migration[5.2]
  def change
    create_table :personnes_morales, id: :uuid do |t|
      t.string :denomination
      t.string :sigle
      t.string :forme_juridique
      t.string :associe_unique
      t.string :activite_principale
      t.string :type_capital
      t.float :capital
      t.float :capital_actuel
      t.string :devise
      t.string :date_cloture
      t.date :date_cloture_exeptionnelle
      t.string :economie_sociale_solidaire
      t.integer :duree_pm
      t.belongs_to :dossier_entreprise, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
