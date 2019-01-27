class CreateTitmcEntreprises < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_entreprises, id: :uuid do |t|
      t.string 'code_greffe'
      t.string 'siren'
      t.string 'numero_gestion'
      t.string :denomination
      t.string :nom_patronyme
      t.string :prenoms
      t.string :forme_juridique
      t.string :associe_unique
      t.string :date_naissance
      t.string :ville_naissance
      t.string :code_activite
      t.string :activite_principale
      t.string :capital
      t.string :devise
      t.string :capital_actuel
      t.string :duree_pm
      t.string :date_cloture
      t.string :nom_usage
      t.string :pseudonyme
      t.string :sigle
      t.string :nom_commercial
      t.string :greffe_siege
      t.string :status_edition_extrait
      t.string :date_cloture_exceptionnelle
      t.string :domiciliataire_nom
      t.string :domiciliataire_rcs
      t.string :eirl
      t.string :dap_denomnimation
      t.string :dap_object
      t.string :dap_date_cloture
      t.string :auto_entrepreneur
      t.string :economie_sociale_solidaire
      t.string :dossier_entreprise_id

      t.timestamps
    end
  end
end
