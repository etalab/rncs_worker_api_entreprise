FactoryBot.define do
  factory :titmc_entreprise, class: TribunalInstance::Entreprise do
    dossier_entreprise
    forme_juridique { '9999' }

    after :create do |entreprise|
      create :adresse_siege, entreprise: entreprise
      create :adresse_domiciliataire, entreprise: entreprise
      create :adresse_dap, entreprise: entreprise
      create_list :titmc_etablissement, 2, entreprise: entreprise
      create_list :titmc_representant, 2, entreprise: entreprise
    end
  end
end
