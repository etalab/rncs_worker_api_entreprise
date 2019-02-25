FactoryBot.define do
  factory :titmc_acte, class: TribunalInstance::Acte do
    numero_depot_manuel { '666' }
    type_acte { 'AA' }
    nature { 'DI' }
  end
end
