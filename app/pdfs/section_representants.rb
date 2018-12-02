module SectionRepresentants
  include Prawn::View
  include PdfHelper

  def section_representants(representants:, **)
    display_section_title 'Gestion, Direction, Adminisration, Contrôle, Associés ou Membres'

    representants.each do |rep|
      @current_rep = rep
      display_table_block data_table_rep
      move_down 10
    end
  end

  private

  def data_table_rep
    data_table = [['Qualité', "<b>#{@current_rep[:qualite]}</b>"]]

    case @current_rep[:type_representant]&.downcase
    when /physique/
      data_table += representant_pp
    when /morale/
      data_table += representant_pm
    else
      Raven.capture_message "Unhandled type_representant (#{@current_rep[:type_representant]})"
    end

    data_table << ['Adresse', adresse_representant]

    data_table
  end

  def representant_pp
    [
      ['Nom, prénoms',              "#{@current_rep[:nom_patronyme]&.upcase}, #{@current_rep[:prenoms]}"],
      ['Date et lieu de naissance', "#{@current_rep[:date_naissance]} #{@current_rep[:ville_naissance]}"],
      ['Nationalité',               @current_rep[:nationalite]]
    ]
  end

  def representant_pm
    [
      ['Dénomination',    @current_rep[:denomination]],
      ['SIREN',           pretty_siren(@current_rep[:siren_pm])],
      ['Forme juridique', @current_rep[:forme_juridique]]
    ]
  end

  def adresse_representant
    [
      @current_rep[:adresse_ligne_1],
      @current_rep[:adresse_ligne_2],
      @current_rep[:adresse_ligne_3],
      @current_rep[:adresse_code_postal],
      @current_rep[:adresse_ville]
    ].compact.join(' ')
  end
end
