class Etablissement
  module Operation
    class Test < Trailblazer::Operation
      step Model(Etablissement, :new)
      step Trailblazer::Operation::Contract::Build(constant: Etablissement::Contract::Test)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
