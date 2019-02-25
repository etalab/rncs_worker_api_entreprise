FactoryBot.define do
  factory :titmc_observation, class: TribunalInstance::Observation do
    code { 'C18' }
    numero { '1234' }
    texte { 'ceci est une observation' }
  end
end
