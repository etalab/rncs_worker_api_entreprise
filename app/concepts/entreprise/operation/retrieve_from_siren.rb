class Entreprise
  module Operation
    class RetrieveFromSiren < Trailblazer::Operation
      step :find


      def find(ctx, params:, **)
        entreprise = Entreprise.find_by(siren: params[:siren])
        params[:entreprise_id] = entreprise.id
      end
    end
  end
end
