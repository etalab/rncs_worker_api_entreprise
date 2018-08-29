class Entreprise
  module Operation
    class CreateWithPP < Trailblazer::Operation
      step Model(Entreprise, :new)
      step Trailblazer::Operation::Contract::Build(constant: Entreprise::Contract::CreateWithPP)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
