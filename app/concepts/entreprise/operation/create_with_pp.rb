module Entreprise
  module Operation
    class CreateWithPP < Trailblazer::Operation
      step Model(DossierEntreprise, :new)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist(method: :sync)
    end
  end
end