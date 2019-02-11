FactoryBot.define do
  factory :titmc_entreprise, class: TribunalInstance::Entreprise do
    dossier_entreprise
    forme_juridique { '9999' }

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

      create_list :titmc_acte, 5,
        entreprise: entreprise,
        code_greffe: entreprise.code_greffe

      create_list :titmc_bilan, 3,
        entreprise: entreprise,
        code_greffe: entreprise.code_greffe

      create_list :titmc_observation, 4,
        entreprise: entreprise,
        code_greffe: entreprise.code_greffe
    end
  end
end
