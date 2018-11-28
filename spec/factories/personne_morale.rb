FactoryBot.define do
  factory :personne_morale do
    denomination { 'Willy Wonka Candies Factory' }
    sigle { 'WWCF' }
    forme_juridique { 'Société de bonbons à responsabilité limitée' }
    associe_unique { '' }
    activite_principale { 'Manger' }
    type_capital { 'F' }
    capital { '1000.0' }
    capital_actuel { '' }
    devise { 'EuRoS' } # it's randomly written Euros, euros, EUROS
    date_cloture { '31 Décembre' }
    date_cloture_exeptionnelle { '' }
    economie_sociale_solidaire { 'Non' }
    duree_pm { '99' }
    libelle_derniere_modification { 'Création' }
    date_derniere_modification { '1967-03-27' }
    code_greffe { '3232' }
    numero_gestion { '1967D00987' }
  end
end
