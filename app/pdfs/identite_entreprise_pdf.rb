class IdentiteEntreprisePdf < Prawn::Document
  # /!\ including that many modules can create conflict in method's names
  # make sure none of these modules share a same method name...
  # good specs make it safe
  include SectionEtablissementPrincipal
  include SectionIdentitePM
  include SectionIdentitePP
  include SectionObservations
  include SectionRepresentants
  include SectionBODACC
  include SectionTitle

  def initialize(dossier_entreprise_greffe_principal:)
    super margin: [50, 30, 50, 30]

    @dossier = dossier_entreprise_greffe_principal

    configure_text_options
    build_pdf
    footer
  end

  private

  def configure_text_options
    default_leading 2
    setup_utf8_font
  end

  def setup_utf8_font
    font_path = 'public/fonts/Source_Sans_Pro'
    font_families.update('Source Sans Pro' => {
      normal: "#{font_path}/SourceSansPro-Regular.ttf",
      italic: "#{font_path}/SourceSansPro-Italic.ttf",
      bold: "#{font_path}/SourceSansPro-Bold.ttf",
      bold_italic: "#{font_path}/SourceSansPro-BoldItalic.ttf"
    })

    font 'Source Sans Pro'
  end

  # rubocop:disable Metrics/AbcSize
  def build_pdf
    section_title @dossier
    move_down 20
    section_identite
    move_down 20
    section_representants @dossier if @dossier[:representants].any?
    move_down 20
    section_etablissement_principal @dossier
    move_down 20
    section_observations @dossier if @dossier[:observations].any?
    move_down 20
    section_bodacc @dossier
  end
  # rubocop:enable Metrics/AbcSize

  def section_identite
    if personne_morale?
      section_identite_pm @dossier
    else
      section_identite_pp @dossier
    end
  end

  def personne_morale?
    @dossier[:personne_morale]
  end

  def footer
    footer_infos
    page_numbering
  end

  def page_numbering
    string = 'page <page>/<total>'
    height_position = -30
    width_page_numbering = 150
    options = {
      at: [bounds.right - width_page_numbering, height_position],
      width: width_page_numbering,
      align: :right
    }

    number_pages string, options
  end

  def footer_infos
    repeat(:all) do
      height_position = -40
      padding_left = 200
      draw_text 'Ces informations sont issues du RNCS', at: [bounds.left + padding_left, height_position]
    end
  end
end
