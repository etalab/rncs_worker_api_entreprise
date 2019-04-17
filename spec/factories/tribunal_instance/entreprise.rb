FactoryBot.define do
  factory :titmc_entreprise_empty, class: TribunalInstance::Entreprise do
    dossier_entreprise
    forme_juridique { '9999' }

    factory :titmc_entreprise_incomplete do
      after :create do |entreprise|
        create_list :titmc_etablissement_empty, 2,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create_list :titmc_representant_empty, 2,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe
      end
    end

    factory :titmc_entreprise do
      after :create do |entreprise|
        create :adresse_siege,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create :adresse_domiciliataire,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create :adresse_dap,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create_list :titmc_etablissement, 2,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create_list :titmc_representant, 2,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe

        create_list :titmc_observation, 4,
          entreprise: entreprise,
          code_greffe: entreprise.code_greffe
      end
    end
  end
end
