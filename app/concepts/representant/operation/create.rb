class Representant
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Entreprise::Operation::RetrieveFromSiren)
      step Model(Representant, :new)
      step Trailblazer::Operation::Contract::Build(constant: Representant::Contract::Create)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist(method: :sync)
    end
  end
end
