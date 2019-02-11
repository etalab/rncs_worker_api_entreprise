FactoryBot.define do
  factory :titmc_observation, class: TribunalInstance::Observation do
    code { 'J41' }
    texte { 'ceci est une observation' }
  end
end
