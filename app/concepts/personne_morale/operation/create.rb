class PersonneMorale
  module Operation
    class Create < Trailblazer::Operation
      step Model(PersonneMorale, :new)
      step Trailblazer::Operation::Contract::Build(constant: PersonneMorale::Contract::Create)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
    end
  end
end
