class API::PdfController< ApplicationController
  def show
    render json: { errors: 'siren invalid' }, status: 400 and return unless Siren.new(siren).valid?
    render json: { errors: 'siren not found' }, status: 404 and return if aucun_dossier
    render json: { errors: 'data is corrupt or incomplete and cannot be served' }, status: 500 and return if cannot_serve
    render json: { errors: 'aucun établissement principal trouvé sur l\'inscription principale' }, status: 500 and return if no_etab_principal_found

    send_data pdf.render,
              filename: "infos_#{siren}.pdf",
              type: 'application/pdf'
  end

  private

  def pdf
    @pdf ||= SirenInfosPdf.new(dossier_principal)
  end

  def siren
    params.require(:siren)
  end

  def dossiers
    @dossiers ||= DossierEntreprise.where(siren: siren)
  end

  def dossier_principal
    @dossier_principal ||= dossiers.find_by(type_inscription: 'P')
  end

  def cannot_serve
    dossier_principal_inexistant || trop_inscriptions_en_greffe_principal
  end

  def aucun_dossier
    dossiers.empty?
  end

  def dossier_principal_inexistant
    dossier_principal.nil?
  end

  def trop_inscriptions_en_greffe_principal
    dossiers.where(type_inscription: 'P').count > 1
  end

  def no_etab_principal_found
    dossier_principal.etablissement_principal.nil?
  end
end
