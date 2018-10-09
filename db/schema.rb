# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_04_134947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "daily_update_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code_greffe"
    t.integer "num_transmission"
    t.string "files_path"
    t.string "status"
    t.uuid "daily_update_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_update_id"], name: "index_daily_update_units_on_daily_update_id"
  end

  create_table "daily_updates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "year"
    t.string "month"
    t.string "day"
    t.string "files_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "proceeded"
  end

  create_table "dossiers_entreprises", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code_greffe"
    t.string "nom_greffe"
    t.string "numero_gestion"
    t.string "siren"
    t.string "type_inscription"
    t.string "date_immatriculation"
    t.string "date_premiere_immatriculation"
    t.string "date_radiation"
    t.string "date_transfert"
    t.string "sans_activite"
    t.string "date_debut_activite"
    t.string "date_debut_premiere_activite"
    t.string "date_cessation_activite"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "etablissements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type_etablissement"
    t.string "siege_pm"
    t.string "rcs_registre"
    t.string "domiciliataire_nom"
    t.string "domiciliataire_siren"
    t.string "domiciliataire_greffe"
    t.string "domiciliataire_complement"
    t.string "siege_domicile_representant"
    t.string "nom_commercial"
    t.string "enseigne"
    t.string "activite_ambulante"
    t.string "activite_saisonniere"
    t.string "activite_non_sedentaire"
    t.string "date_debut_activite"
    t.string "activite"
    t.string "origine_fonds"
    t.string "origine_fonds_info"
    t.string "type_exploitation"
    t.string "id_etablissement"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dossier_entreprise_id"
    t.string "adresse_ligne_1"
    t.string "adresse_ligne_2"
    t.string "adresse_ligne_3"
    t.string "adresse_code_postal"
    t.string "adresse_ville"
    t.string "adresse_code_commune"
    t.string "adresse_pays"
    t.string "code_greffe"
    t.string "numero_gestion"
    t.string "siren"
  end

  create_table "observations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "id_observation"
    t.string "numero"
    t.string "date_ajout"
    t.string "date_suppression"
    t.text "texte"
    t.string "etat"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dossier_entreprise_id"
    t.string "code_greffe"
    t.string "numero_gestion"
    t.string "siren"
  end

  create_table "personnes_morales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "denomination"
    t.string "sigle"
    t.string "forme_juridique"
    t.string "associe_unique"
    t.string "activite_principale"
    t.string "type_capital"
    t.string "capital"
    t.string "capital_actuel"
    t.string "devise"
    t.string "date_cloture"
    t.string "date_cloture_exeptionnelle"
    t.string "economie_sociale_solidaire"
    t.string "duree_pm"
    t.string "libelle_derniere_modification"
    t.string "date_derniere_modification"
    t.uuid "dossier_entreprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code_greffe"
    t.string "numero_gestion"
    t.string "siren"
  end

  create_table "personnes_physiques", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "activite_forain"
    t.string "dap"
    t.string "dap_denomination"
    t.string "dap_objet"
    t.string "dap_date_cloture"
    t.string "eirl"
    t.string "auto_entrepreneur"
    t.string "conjoint_collab_date_fin"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dossier_entreprise_id"
    t.string "nom_patronyme"
    t.string "nom_usage"
    t.string "pseudonyme"
    t.string "prenoms"
    t.string "date_naissance"
    t.string "ville_naissance"
    t.string "pays_naissance"
    t.string "nationalite"
    t.string "conjoint_collab_nom_patronyme"
    t.string "conjoint_collab_nom_usage"
    t.string "conjoint_collab_pseudonyme"
    t.string "conjoint_collab_prenoms"
    t.string "adresse_ligne_1"
    t.string "adresse_ligne_2"
    t.string "adresse_ligne_3"
    t.string "adresse_code_postal"
    t.string "adresse_ville"
    t.string "adresse_code_commune"
    t.string "adresse_pays"
    t.string "dap_adresse_ligne_1"
    t.string "dap_adresse_ligne_2"
    t.string "dap_adresse_ligne_3"
    t.string "dap_adresse_code_postal"
    t.string "dap_adresse_ville"
    t.string "dap_adresse_code_commune"
    t.string "dap_adresse_pays"
    t.string "code_greffe"
    t.string "numero_gestion"
    t.string "siren"
  end

  create_table "representants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "denomination"
    t.string "forme_juridique"
    t.string "siren_pm"
    t.string "type_representant"
    t.string "qualite"
    t.string "conjoint_collab_date_fin"
    t.string "id_representant"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dossier_entreprise_id"
    t.string "adresse_ligne_1"
    t.string "adresse_ligne_2"
    t.string "adresse_ligne_3"
    t.string "adresse_code_postal"
    t.string "adresse_ville"
    t.string "adresse_code_commune"
    t.string "adresse_pays"
    t.string "representant_permanent_adresse_ligne_1"
    t.string "representant_permanent_adresse_ligne_2"
    t.string "representant_permanent_adresse_ligne_3"
    t.string "representant_permanent_adresse_code_postal"
    t.string "representant_permanent_adresse_ville"
    t.string "representant_permanent_adresse_code_commune"
    t.string "representant_permanent_adresse_pays"
    t.string "nom_patronyme"
    t.string "nom_usage"
    t.string "pseudonyme"
    t.string "prenoms"
    t.string "date_naissance"
    t.string "ville_naissance"
    t.string "pays_naissance"
    t.string "nationalite"
    t.string "representant_permanent_nom_patronyme"
    t.string "representant_permanent_nom_usage"
    t.string "representant_permanent_pseudonyme"
    t.string "representant_permanent_prenoms"
    t.string "representant_permanent_date_naissance"
    t.string "representant_permanent_ville_naissance"
    t.string "representant_permanent_pays_naissance"
    t.string "representant_permanent_nationalite"
    t.string "conjoint_collab_nom_patronyme"
    t.string "conjoint_collab_nom_usage"
    t.string "conjoint_collab_pseudonyme"
    t.string "conjoint_collab_prenoms"
    t.string "code_greffe"
    t.string "numero_gestion"
    t.string "siren"
  end

  create_table "stock_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code_greffe"
    t.integer "number"
    t.string "file_path"
    t.string "status"
    t.uuid "stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_units_on_stock_id"
  end

  create_table "stocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "year"
    t.string "month"
    t.string "day"
    t.string "files_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "daily_update_units", "daily_updates"
  add_foreign_key "stock_units", "stocks"
end
