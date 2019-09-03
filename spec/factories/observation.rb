FactoryBot.define do
  factory :observation do
    id_observation { '12' }
    numero { '4000A' }
    date_ajout { '12/12/12' }
    date_suppression { nil }
    texte { 'This is a very long observation, so long that you could not imagine it before reading it.' }
    etat { 'soeur' }
    dossier_entreprise

    factory :random_observation do
      date_ajout { Faker::Date.between(from: 1.year.ago, to: 1.year.from_now).to_s }
    end
  end
end
