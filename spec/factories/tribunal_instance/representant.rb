FactoryBot.define do
  factory :titmc_representant, class: TribunalInstance::Representant do
    association :entreprise, factory: :titmc_entreprise

    type_representant { 'PM' }

    after :create do |rep|
      create :adresse_representant,
        representant: rep,
        code_greffe: rep.code_greffe

      create :adresse_representant_permanent,
        representant: rep,
        code_greffe: rep.code_greffe
    end
  end
end
