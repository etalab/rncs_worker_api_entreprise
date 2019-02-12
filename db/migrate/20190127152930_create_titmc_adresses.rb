class CreateTitmcAdresses < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_adresses, id: :uuid do |t|
      t.string :type
      t.string :ligne_1
      t.string :ligne_2
      t.string :residence
      t.string :numero_voie
      t.string :type_voie
      t.string :nom_voie
      t.string :localite
      t.string :code_postal
      t.string :bureau_et_cedex
      t.string :pays
      t.string :entreprise_id
      t.string :etablissement_id

      t.timestamps
    end
  end
end
