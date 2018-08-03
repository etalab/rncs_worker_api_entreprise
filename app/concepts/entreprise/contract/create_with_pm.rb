class Entreprise
  module Contract
    class CreateWithPM < Entreprise::Contract::Create
      # Entreprise's fields are inherited from Entreprise::Contract::Create

      property :personne_morale, form: PersonneMorale::Contract::Create, populate_if_empty: PersonneMorale
    end
  end
end
