class CreateTitmcBilan < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_bilans, id: :uuid do |t|
      t.string 'date_cloture_annee'
      t.string 'date_cloture_jour_mois'
      t.string 'date_depot'
      t.string 'confidentialite_document_comptable'
      t.string 'confidentialite_compte_resultat'
      t.string 'numero'
      t.string 'duree_exercice'
      t.string 'entreprise_id'

      t.timestamps
    end
  end
end
