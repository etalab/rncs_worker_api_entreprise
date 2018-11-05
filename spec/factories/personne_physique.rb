FactoryBot.define do
  factory :personne_physique do
    activite_forain { 'Non' }
    dap { 'Non' }
    eirl { 'Non' }
    date_derniere_modification { '2018-01-01' }
    libelle_derniere_modification { 'Création' }
    nom_patronyme { 'dupont' }
    prenoms { 'François Philippe' }
    date_naissance { '1970-01-05' }
    ville_naissance { 'Marseille' }
    nationalite { 'Française' }
    adresse_ligne_2 { '1 AVENUE DES CHAMPS ELYSEES' }
    adresse_ligne_3 { 'BEL HOTEL' }
    adresse_code_postal { '75008' }
    adresse_ville { 'PARIS' }
    adresse_pays { 'FRANCE' }
    code_greffe { '5678' }
    numero_gestion { '1988A00543' }
  end
end
