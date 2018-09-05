class Entreprise
  module Operation
    class RetrieveFromSiren < Trailblazer::Operation
      step :find


      def find(ctx, params:, siren_in_db:, **)
        # https://docs.ruby-lang.org/en/2.0.0/Array.html#method-i-assoc :troll:
        # siren_in_db => [[siren:, uid:], ...]
        _, entreprise_uid = siren_in_db.assoc(params[:siren].to_s)
        params[:entreprise_id] = entreprise_uid
      end
    end
  end
end
