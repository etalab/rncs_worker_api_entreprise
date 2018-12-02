FactoryBot.define do
  factory :etablissement, aliases: [:etablissement_address_incomplete] do
    dossier_entreprise
    type_etablissement { 'SEC' }
    siege_pm { 'France' }
    rcs_registre { 'Pointe à Pitre' }
    activite_ambulante { 'non' }
    activite_saisonniere { 'non' }
    activite_non_sedentaire { 'non' }
    date_debut_activite { '1992-07-09' }
    activite { 'Mangeur de bananes professionnel' }
    origine_fonds { 'Création' }
    type_exploitation { 'Divers' }
    id_etablissement { rand(20) }
    date_derniere_modification { '2010-04-24' }
    libelle_derniere_modification { 'Etablissement ouvert' }
    adresse_ligne_2 { 'Rue des cocotiers' }
    adresse_code_postal { '97114' }
    adresse_ville { 'Trois-Rivières' }
    adresse_code_commune { 'Goyave' }
    adresse_pays { 'fRanCe' }
    code_greffe { '9876' }
    numero_gestion { '1998B00777' }

    factory :siege_social do
      type_etablissement { 'SIE' }
    end

    factory :etablissement_principal do
      type_etablissement { 'PRI' }
    end

    factory :siege_social_and_principal do
      type_etablissement { 'SEP' }
    end

    factory :etablissement_address_complete do
      adresse_ligne_1 { 'C\'est ici' }
      adresse_ligne_3 { '(Rhumerie)' }
    end

    factory :etablissement_etranger do
      adresse_pays { 'Syldavie' }
    end
  end
end
