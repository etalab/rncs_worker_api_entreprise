module DataSource
  module File
    module PM
      module Operation
        class Save < Trailblazer::Operation
          step Nested(::Entreprise::Operation::Create)
          step ->(ctx, model:, params:, **) { params[:entreprise_id] = model.id }
          step Nested(::PersonneMorale::Operation::Create)
        end
      end
    end
  end
end
