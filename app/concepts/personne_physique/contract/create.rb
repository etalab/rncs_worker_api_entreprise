class PersonnePhysique
  module Contract
    class Create < Reform::Form
      include PopulatorHelper

      property :activite_forain
      property :dap
      property :dap_denomination
      property :dap_objet
      property :dap_date_cloture
      property :eirl
      property :auto_entrepreneur
      property :conjoint_collaborateur_date_fin
    end
  end
end
