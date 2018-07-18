class Observation
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Entreprise::Operation::RetrieveFromSiren)
      step Model(Observation, :new)
      step Trailblazer::Operation::Contract::Build(constant: Observation::Contract::Create)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
