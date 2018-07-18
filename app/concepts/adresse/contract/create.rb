class Adresse
  module Contract
    class Create < Reform::Form
      property :ligne_1
      property :ligne_2
      property :ligne_3
      property :code_postal
      property :ville
      property :code_commune
      property :pays
    end
  end
end
