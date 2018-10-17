class API::InfosIdentiteEntrepriseRNCSController< ApplicationController
  def show
    render json: {}, status: 400 and return unless Siren.new(siren).valid?
    render json: {}, status: 404 and return if aucun_dossier
    render json: {errors: 'data is corrupt or incomplete and cannot be served'}, status: 500 and return if cannot_serve

    json = {
      dossier_entreprise_greffe_principal: dossier_principal.attributes
    }

    json[:dossier_entreprise_greffe_principal][:observations]       = dossier_principal.observations.map(&:attributes)
    json[:dossier_entreprise_greffe_principal][:representants]      = dossier_principal.representants.map(&:attributes)
    json[:dossier_entreprise_greffe_principal][:etablissements]     = dossier_principal.etablissements.map(&:attributes)
    json[:dossier_entreprise_greffe_principal][:personne_morale]    = dossier_principal&.personne_morale&.attributes
    json[:dossier_entreprise_greffe_principal][:personne_physique]  = dossier_principal&.personne_physique&.attributes

    render json: json, status: 200
  end

  private
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
    dossier_principal_inexistant ||
    trop_inscriptions_en_greffe_principal
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
end
