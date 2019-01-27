FactoryBot.define do
  factory :titmc_etablissement, class: TribunalInstance::Etablissement do
    precedent_exploitant_nom { 'me' }
    association :entreprise, factory: :titmc_entreprise

    after :create do |etab|
      create :adresse_etablissement, etablissement: etab
    end
  end
end
