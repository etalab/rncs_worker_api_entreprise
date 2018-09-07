class Etablissement
  module Contract
    class Test < Reform::Form
      property :enseigne
      property :entreprise_id

      property :adresse,
               form: Adresse::Contract::Create,
               populate_if_empty: Adresse,
               skip_if: (lambda do |options|
                # options[:fragment] contains adresse params fields
                options[:fragment]
               end)

      validation do
        required(:enseigne).filled
        required(:entreprise_id).filled
      end
    end
  end
end
