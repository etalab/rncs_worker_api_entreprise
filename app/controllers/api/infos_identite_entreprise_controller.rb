class API::InfosIdentiteEntrepriseController< ApplicationController
  def show
    retrieve_identity = Entreprise::Operation::Identity.call(siren: siren)

    if retrieve_identity.success?
      render json: retrieve_identity[:entreprise_identity], status: 200
    else
      http_error = retrieve_identity[:http_error]
      render json: { error: http_error[:message] }, status: http_error[:code]
    end
  end

  def pdf
    retrieve_identity = Entreprise::Operation::Identity.call(siren: siren)

    if retrieve_identity.success?
      pdf = IdentiteEntreprisePdf.new retrieve_identity[:entreprise_identity]
      send_data(pdf.render, filename: "infos_#{siren}.pdf", type: 'application/pdf')
    else
      http_error = retrieve_identity[:http_error]
      render json: { error: http_error[:message] }, status: http_error[:code]
    end
  end

  private

  def siren
    params.require(:siren)
  end
end
