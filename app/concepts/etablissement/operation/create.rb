class Etablissement
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Entreprise::Operation::RetrieveFromSiren)
      step Model(Etablissement, :new)
      step Trailblazer::Operation::Contract::Build(constant: Etablissement::Contract::Create)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
