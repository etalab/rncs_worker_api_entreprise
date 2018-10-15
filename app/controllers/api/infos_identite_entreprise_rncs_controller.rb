class API::InfosIdentiteEntrepriseRNCSController< ApplicationController
  def show
    if Siren.new(siren).valid?
      render json: {}
    else
      render json: {}, status: 400
    end
  end

  private
  def siren
    params.require(:siren)
  end
end
