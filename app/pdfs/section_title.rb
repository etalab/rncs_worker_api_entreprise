module SectionTitle
  include Prawn::View

  def section_title(arg)
    @arg = arg

    text("#{arg[:nom_greffe]} (code greffe: #{arg[:code_greffe]})")
    text("Numéro de gestion: #{arg[:numero_gestion]}")

    move_down(20)
    display_headline

    text(
      "en date du #{pretty_db_current_date}",
      style: :italic,
      align: :center
    )
  end

  private

  def display_headline
    text(
      'Extrait d\'immatriculation principale au registre national du commerce et des sociétés',
      align: :center,
      style: :bold,
      size:  12
    )
  end

  def pretty_db_current_date
    I18n.l(db_current_date, format: '%d %B %Y')
  end

  def db_current_date
    Date.parse(@arg[:db_current_date])
  end
end
