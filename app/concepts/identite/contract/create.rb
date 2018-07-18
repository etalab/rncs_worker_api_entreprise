class Identite
  module Contract
    class Create < Reform::Form
      property :nom_patronyme
      property :nom_usage
      property :pseudonyme
      property :prenoms
      property :date_naissance
      property :ville_naissance
      property :pays_naissance
      property :nationalite
    end
  end
end
