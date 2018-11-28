module SectionEtablissementPrincipal
  include Prawn::View
  include PdfHelper

  def section_etablissement_principal(etablissement_principal:, **)
    @etablissement_principal = etablissement_principal
    display_section_title 'Renseignements sur l\'établissement principal'

    display_table_block [
      ['Adresse',                adresse_etablissement_principal],
      ['Date début d\'activité', etablissement_principal[:date_debut_activite]],
      ['Type d\'exploitation',   etablissement_principal[:type_exploitation]]
    ]
  end

  private

  def adresse_etablissement_principal
    [
      @etablissement_principal[:adresse_ligne_1],
      @etablissement_principal[:adresse_ligne_2],
      @etablissement_principal[:adresse_ligne_3],
      @etablissement_principal[:adresse_code_postal],
      @etablissement_principal[:adresse_ville]
    ].compact.join(' ')
  end
end
