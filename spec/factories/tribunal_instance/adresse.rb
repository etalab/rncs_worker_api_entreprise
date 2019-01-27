FactoryBot.define do
  factory :adresse_siege, class: TribunalInstance::AdresseSiege do
    ligne_1 { 'Ceci est une adresse de siège' }
  end

  factory :adresse_domiciliataire, class: TribunalInstance::AdresseDomiciliataire do
    ligne_1 { 'Ceci est l adresse du domiciliataire' }
  end

  factory :adresse_dap, class: TribunalInstance::AdresseDAP do
    residence { 'Ceci est une résidence DAP' }
  end

  factory :adresse_etablissement, class: TribunalInstance::AdresseEtablissement do
    association :etablissement, factory: :titmc_etablissement
    ligne_1 { 'Ceci est une adresse d\'établissement' }
  end

  factory :adresse_representant, class: TribunalInstance::AdresseRepresentant do
    association :representant, factory: :titmc_representant
    ligne_1 { 'Ceci est une adresse de représentant' }
  end

  factory :adresse_representant_permanent, class: TribunalInstance::AdresseRepresentantPermanent do
    association :representant, factory: :titmc_representant
    ligne_1 { 'Ceci est une adresse de représentant permanent' }
  end
end
