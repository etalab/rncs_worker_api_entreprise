class PersonnePhysique
  module Operation
    class Create < Trailblazer::Operation
      step Model(PersonnePhysique, :new)
      step Trailblazer::Operation::Contract::Build(constant: PersonnePhysique::Contract::Create)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
