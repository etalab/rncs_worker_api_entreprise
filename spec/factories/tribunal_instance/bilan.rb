FactoryBot.define do
  factory :titmc_bilan, class: TribunalInstance::Bilan do
    numero { '42' }
    confidentialite_document_comptable { '1' }
  end
end
