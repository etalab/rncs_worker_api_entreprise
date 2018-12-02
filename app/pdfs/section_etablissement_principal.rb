module SectionEtablissementPrincipal
  include Prawn::View
  include PdfHelper

  def section_etablissement_principal(etablissement_principal:, **)
    @etablissement_principal = etablissement_principal
    display_section_title 'Renseignements sur l\'établissement principal'

    display_table_block [
      ['Adresse',                build_adresse(@etablissement_principal)],
      ['Date début d\'activité', etablissement_principal[:date_debut_activite]],
      ['Type d\'exploitation',   etablissement_principal[:type_exploitation]]
    ]
  end
end
