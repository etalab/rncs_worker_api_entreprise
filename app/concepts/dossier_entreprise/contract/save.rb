class DossierEntreprise
  module Contract
    class Save < Reform::Form
      property :code_greffe
      property :numero_gestion
      property :siren
    end
  end
end
