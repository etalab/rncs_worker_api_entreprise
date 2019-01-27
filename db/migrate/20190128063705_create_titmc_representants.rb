class CreateTitmcRepresentants < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_representants, id: :uuid do |t|
      t.string 'qualite'
      t.string 'raison_sociale_ou_nom_ou_prenom'
      t.string 'nom_ou_denomination'
      t.string 'prenoms'
      t.string 'type_representant'
      t.string 'date_creation'
      t.string 'date_modification'
      t.string 'date_radiation'
      t.string 'pseudonyme'
      t.string 'date_naissance'
      t.string 'lieu_naissance'
      t.string 'pays_naissance'
      t.string 'nationalite'
      t.string 'nom_usage'
      t.string 'greffe_immatriculation'
      t.string 'siren_ou_numero_gestion'
      t.string 'forme_juridique'
      t.string 'commentaire'
      t.string 'representant_permanent_nom'
      t.string 'representant_permanent_prenoms'
      t.string 'representant_permanent_nom_usage'
      t.string 'representant_permanent_date_naissance'
      t.string 'representant_permanent_ville_naissance'
      t.string 'representant_permanent_pays_naissance'
      t.string 'entreprise_id'

      t.timestamps
    end

    change_table :titmc_adresses do |t|
      t.string :representant_id
    end
  end
end
