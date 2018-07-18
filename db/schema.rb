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

ActiveRecord::Schema.define(version: 2018_07_18_185254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "adresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ligne_1"
    t.string "ligne_2"
    t.string "ligne_3"
    t.string "code_postal"
    t.string "ville"
    t.string "commune"
    t.string "pays"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "addressable_type"
    t.uuid "addressable_id"
    t.index ["addressable_type", "addressable_id"], name: "index_adresses_on_addressable_type_and_addressable_id"
  end

  create_table "entreprises", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["numero_gestion"], name: "index_entreprises_on_numero_gestion"
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
    t.uuid "entreprise_id"
    t.index ["entreprise_id"], name: "index_etablissements_on_entreprise_id"
  end

  create_table "identites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom_patronyme"
    t.string "nom_usage"
    t.string "pseudonyme"
    t.string "prenoms"
    t.string "date_naissance"
    t.string "ville_naissance"
    t.string "pays_naissance"
    t.string "nationalite"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifiable_type"
    t.uuid "identifiable_id"
    t.index ["identifiable_type", "identifiable_id"], name: "index_identites_on_identifiable_type_and_identifiable_id"
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
    t.uuid "entreprise_id"
    t.index ["entreprise_id"], name: "index_observations_on_entreprise_id"
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
    t.uuid "entreprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entreprise_id"], name: "index_personnes_morales_on_entreprise_id"
  end

  create_table "personnes_physiques", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "activite_forain"
    t.string "dap"
    t.string "dap_denomination"
    t.string "dap_objet"
    t.string "dap_date_cloture"
    t.string "eirl"
    t.string "auto_entrepreneur"
    t.string "conjoint_collaborateur_date_fin"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "entreprise_id"
    t.index ["entreprise_id"], name: "index_personnes_physiques_on_entreprise_id"
  end

  create_table "representants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "denomination"
    t.string "forme_juridique"
    t.string "siren_pm"
    t.string "type_representant"
    t.string "qualite"
    t.string "conjoint_collaborateur_date_fin"
    t.string "id_representant"
    t.string "date_derniere_modification"
    t.string "libelle_derniere_modification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "entreprise_id"
    t.index ["entreprise_id"], name: "index_representants_on_entreprise_id"
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

  add_foreign_key "etablissements", "entreprises"
  add_foreign_key "observations", "entreprises"
  add_foreign_key "personnes_morales", "entreprises"
  add_foreign_key "personnes_physiques", "entreprises"
  add_foreign_key "representants", "entreprises"
end
