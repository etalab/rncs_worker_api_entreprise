module SectionBODACC
  include Prawn::View
  include PdfHelper

  def section_bodacc(siren:, **)
    display_section_title('Bulletin Officiel des Annonces Civiles et Commerciales (BODACC)')
    @siren = siren

    display_table_block([
      ['Lien', link_bodacc]
    ])
  end

  private

  def link_bodacc
    "<link href='#{url}'><color rgb='0000FF'>#{url}</color></link>"
  end

  def url
    "https://www.bodacc.fr/annonce/liste/#{@siren}"
  end
end
