module PdfHelper
  include Prawn::View

  def display_section_title(title)
    text(title, style: :bold)

    stroke_horizontal_rule
    move_down(5)
  end

  def pretty_siren(siren)
    # 111 111 111
    siren.dup&.insert(6, ' ')&.insert(3, ' ')
  end

  # /!\ there is no test that makes sure this works
  # only human made tests
  def display_table_block(data, column_width = 200)
    current_table = make_table(data,
      column_widths: { 0 => column_width },
      cell_style: {
        border_width: 0,
        padding: [0, 0, 2, 0],
        inline_format: true
      })

    real_margin_bottom = 30
    start_new_page if (cursor - current_table.height - real_margin_bottom).negative?
    current_table.draw
  end

  def build_adresse(etablissement)
    [
      etablissement[:adresse_ligne_1],
      etablissement[:adresse_ligne_2],
      etablissement[:adresse_ligne_3],
      etablissement[:adresse_code_postal],
      etablissement[:adresse_ville],
      build_pays(etablissement)
    ].compact.join(' ')
  end

  def build_pays(etablissement)
    return if etablissement[:adresse_pays].nil?
    return if etablissement[:adresse_pays].downcase =~ /france/

    "(#{etablissement[:adresse_pays]})"
  end
end
