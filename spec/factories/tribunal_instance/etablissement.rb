FactoryBot.define do
  factory :titmc_etablissement, class: TribunalInstance::Etablissement do
    association :entreprise, factory: :titmc_entreprise

    precedent_exploitant_nom { 'me' }

    after :create do |etab|
      create :adresse_etablissement,
        etablissement: etab,
        code_greffe: etab.code_greffe
    end
  end
end
