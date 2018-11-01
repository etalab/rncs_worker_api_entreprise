class SirenInfosPdf < Prawn::Document
  def initialize(dossier_entreprise)
    super(top_margin: 30)

    @dossier = dossier_entreprise

    setup_utf8_font
    build_pdf
  end

  private

  def build_pdf
    header_section
    identite_section
    representants_section
    etablissement_principal_section
  end

  def setup_utf8_font
    font_path = "public/fonts/Source_Sans_Pro"
    font_families.update('Source Sans Pro' => {
      normal:      "#{font_path}/SourceSansPro-Regular.ttf",
      italic:      "#{font_path}/SourceSansPro-Italic.ttf",
      bold:        "#{font_path}/SourceSansPro-Bold.ttf",
      bold_italic: "#{font_path}/SourceSansPro-BoldItalic.ttf"
    })

    font 'Source Sans Pro'
  end

  def header_section
    text "#{@dossier.nom_greffe} (code greffe: #{@dossier.code_greffe})"
    text "Numéro de gestion: #{@dossier.numero_gestion}"

    move_down 20
    text 'Informations d\'identité d\'entreprise', align: :center, style: :bold, size: 14
    text "En date du #{DateTime.now.strftime("%d %B %Y")}", style: :italic, align: :center
  end

  def identite_section
    move_down 20
    text 'Identité de l\'entreprise', style: :bold
    text "SIREN: #{pretty_siren(@dossier.siren)}"
    text "Date d'immatriculation: #{@dossier.date_immatriculation}"

    if personne_morale?
      section_identite_pm
    else
      section_identite_pp
    end
  end

  def section_identite_pm
    text "Dénomination: #{pm&.denomination}"
    text "Forme juridique: #{pm&.forme_juridique}"
    text "Capital: #{pm&.capital} #{pm&.devise}"
    text "Adresse: #{adresse_etablissement_principal}"
    text "Durée: #{duree_pm}"
    text "Date de clôture: #{pm&.date_cloture}"
  end

  def section_identite_pp
    text "Dénomination: #{pp&.nom_patronyme} #{pp&.prenoms}"
    text "Date et lieu de naissance: #{pp&.date_naissance} #{pp&.ville_naissance}"
    text "Adresse du siège: #{adresse_pp}"
  end

  def representants_section
    move_down 20
    text 'Représentants', style: :bold

    @dossier.representants.map do |rep|
      text "Qualité: #{rep.qualite}"

      case rep.type_representant
      when 'P.Physique'
        representant_pp rep
      when 'P. Morale'
        representant_pm rep
      end

      text "Adresse: #{adresse_representant(rep)}"
    end
  end

  def etablissement_principal_section
    move_down 20
    text 'Renseignements sur l\'établissement principal', style: :bold
    text "Adresse: #{adresse_etablissement_principal}"
    text "Date début d'activité: #{@dossier.etablissement_principal&.date_debut_activite}"
    text "Type d'exploitation: #{@dossier.etablissement_principal&.type_exploitation}"
  end

  def personne_morale?
    !pm.nil?
  end

  def pretty_siren(siren)
    # 111 111 111
    siren&.insert(6, ' ')&.insert(3, ' ')
  end

  def pp
    @dossier.personne_physique
  end

  def pm
    @dossier.personne_morale
  end

  def representant_pp(rep)
    text "Nom prénoms: #{rep.nom_patronyme} #{rep.prenoms}"
    text "Date et lieu de naissance: #{rep.date_naissance} #{rep.ville_naissance}"
    text "Nationalité: #{rep.nationalite}"
  end

  def representant_pm(rep)
    text "Dénomination: #{rep.denomination}"
    text "SIREN: #{pretty_siren(rep.siren_pm)}"
    text "Forme juridique: #{rep.forme_juridique}"
  end

  def adresse_etablissement_principal
    [
      @dossier.etablissement_principal&.adresse_ligne_1,
      @dossier.etablissement_principal&.adresse_ligne_2,
      @dossier.etablissement_principal&.adresse_ligne_3,
      @dossier.etablissement_principal&.adresse_code_postal,
      @dossier.etablissement_principal&.adresse_ville
    ].compact.join(' ')
  end

  def adresse_pp
    [
      pp&.adresse_ligne_1,
      pp&.adresse_ligne_2,
      pp&.adresse_ligne_3
    ].compact.join(' ')
  end

  def duree_pm
    (DateTime.now + pm.duree_pm.to_i.years)
      .strftime('%d/%m/%Y')
  end

  def adresse_representant(rep)
    [
      rep.adresse_ligne_1,
      rep.adresse_ligne_2,
      rep.adresse_ligne_3,
      rep.adresse_code_postal,
      rep.adresse_ville
    ].compact.join(' ')
  end
end
