class CreateDossiersEntreprises < ActiveRecord::Migration[5.2]
  def change
    create_table :dossiers_entreprises, id: :uuid do |t|
      t.string :code_greffe
      t.string :nom_greffe
      t.string :numero_gestion, index: true
      t.string :siren
      t.string :type_inscription
      t.date :date_immatriculation
      t.date :date_premiere_immatriculation
      t.date :date_radiation
      t.date :date_transfert
      t.string :sans_activite
      t.date :date_debut_activite
      t.date :date_debut_premiere_activite
      t.date :date_cessation_activite
      t.date :date_derniere_modification
      t.string :libelle_derniere_modification

      t.timestamps
    end
  end
end
