FactoryBot.define do
  factory :titmc_acte, class: TribunalInstance::Acte do
    type_acte { 'AA' }
    nature { 'DI' }
  end
end
