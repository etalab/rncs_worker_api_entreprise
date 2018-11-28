module SectionIdentitePP
  include Prawn::View
  include PdfHelper

  def section_identite_pp(personne_physique:, date_immatriculation:, **)
    @personne_physique = personne_physique

    display_section_title 'Identification de la personne physique'

    display_table_block [
      ['SIREN',                     pretty_siren(personne_physique[:siren])],
      ['Date d\'immatriculation',   date_immatriculation],
      ['Nom, prénoms',              nom_prenoms],
      ['Date et lieu de naissance', date_lieu_naissance],
      ['Nationalité',               @personne_physique[:nationalite]],
      ['Domicile personnel',        adresse_pp]
    ]
  end

  private

  def nom_prenoms
    "<b>#{@personne_physique[:nom_patronyme]&.upcase} #{@personne_physique[:prenoms]}</b>"
  end

  def date_lieu_naissance
    "#{@personne_physique[:date_naissance]} #{@personne_physique[:ville_naissance]}"
  end

  def adresse_pp
    [
      @personne_physique[:adresse_ligne_1],
      @personne_physique[:adresse_ligne_2],
      @personne_physique[:adresse_ligne_3],
      @personne_physique[:adresse_code_postal],
      @personne_physique[:adresse_ville]
    ].compact.join(' ')
  end
end
