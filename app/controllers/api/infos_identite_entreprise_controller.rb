class API::InfosIdentiteEntrepriseController< ApplicationController
  def show
    retrieve_identity = Entreprise::Operation::Identity.call(siren: siren)

    if retrieve_identity.success?
      render json: retrieve_identity[:entreprise_identity], status: 200
    else
      error = retrieve_identity[:http_error]
      render json: error[:message], status: error[:code]
    end
  end

  def pdf
    retrieve_identity = Entreprise::Operation::Identity.call(siren: siren)

    if retrieve_identity.success?
      dossier_principal = retrieve_identity[:dossier_principal]
      pdf = SirenInfosPdf.new(dossier_principal)
      send_data(pdf.render, filename: "infos_#{siren}.pdf", type: 'application/pdf')
    else
      error = retrieve_identity[:http_error]
      render json: error[:message], status: error[:code]
    end
  end

  private

  def siren
    params.require(:siren)
  end
end
