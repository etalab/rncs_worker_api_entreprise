class Entreprise
  module Operation
    class RetrieveFromSiren < Trailblazer::Operation
      step :find


      def find(ctx, params:, siren_in_db:, **)
        _, entreprise_id = siren_in_db.assoc(params[:siren].to_s)
        params[:entreprise_id] = entreprise_id
      end
    end
  end
end
