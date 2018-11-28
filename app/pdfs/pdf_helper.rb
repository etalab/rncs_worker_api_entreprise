module PdfHelper
  include Prawn::View

  def display_section_title(title)
    text title, style: :bold

    stroke_horizontal_rule
    move_down 5
  end

  def pretty_siren(siren)
    # 111 111 111
    siren.insert(6, ' ').insert(3, ' ')
  end

  # /!\ there is no test that makes sure this works
  # only human made tests
  def display_table_block(data)
    current_table = make_table data,
      column_widths: { 0 => 200 },
      cell_style: {
        :border_width => 0,
        :padding => [0, 0, 2, 0],
        :inline_format => true
      }

      real_margin_bottom = 30
      start_new_page if (cursor - current_table.height - real_margin_bottom).negative?
      current_table.draw
  end
end
