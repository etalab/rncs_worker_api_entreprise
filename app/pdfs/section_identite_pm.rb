module SectionIdentitePM
  include ActionView::Helpers::NumberHelper
  include Prawn::View
  include PdfHelper

  def section_identite_pm(personne_morale:, etablissement_principal:, date_immatriculation:, **)
    @personne_morale = personne_morale
    @etablissement_principal = etablissement_principal
    @date_immatriculation = date_immatriculation

    display_section_title('Identification de la personne morale')

    display_table_block([
      ['SIREN',                                 pretty_siren(personne_morale[:siren])],
      ['Date d\'immatriculation',               date_immatriculation],
      ['Dénomination',                          "<b>#{personne_morale[:denomination]}</b>"],
      ['Forme juridique',                       personne_morale[:forme_juridique]],
      ['Capital',                               capital],
      ['Adresse',                               build_adresse(@etablissement_principal)],
      ['Activités principales',                 etablissement_principal[:activite]],
      ['Durée de la personne morale',           duree_pm],
      ['Date de clôture de l\'exercice social', @personne_morale[:date_cloture]]
    ])
  end

  private

  def capital
    return if @personne_morale[:capital].nil?

    number_to_currency(
      @personne_morale[:capital].to_f,
      unit:      devise_capitalized,
      separator: '.',
      delimiter: ' '
    )
  end

  def devise_capitalized
    @personne_morale[:devise].nil? ? '' : @personne_morale[:devise].capitalize
  end

  def duree_pm
    "#{@personne_morale[:duree_pm]} ans à partir du #{@date_immatriculation}"
  end
end
