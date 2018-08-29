class Entreprise
  module Contract
    class CreateWithPP < Entreprise::Contract::Create
      # Entreprise's fields are inherited from Entreprise::Contract::Create

      property :personne_physique, form: PersonnePhysique::Contract::Create, populate_if_empty: PersonnePhysique
    end
  end
end
