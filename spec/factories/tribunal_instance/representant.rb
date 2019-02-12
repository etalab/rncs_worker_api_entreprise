FactoryBot.define do
  factory :titmc_representant, class: TribunalInstance::Representant do
    association :entreprise, factory: :titmc_entreprise
    type_representant { 'PM' }

    after :create do |rep|
      create :adresse_representant, representant: rep
      create :adresse_representant_permanent, representant: rep
    end
  end
end
