FactoryBot.define do
  factory :titmc_representant_empty, class: TribunalInstance::Representant do
    association :entreprise, factory: :titmc_entreprise

    date_creation { '1900-01-01' }
    qualite { '1200' }
    type_representant { 'PM' }

    factory :titmc_representant, class: TribunalInstance::Representant do
      after :create do |rep|
        create :adresse_representant,
          representant: rep,
          code_greffe:  rep.code_greffe

        create :adresse_representant_permanent,
          representant: rep,
          code_greffe:  rep.code_greffe
      end
    end
  end
end
