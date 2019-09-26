module Entreprise
  module Operation
    class CoverRatio < Trailblazer::Operation
      step :init
      step :find_siren_with_secondary_immat_only
      step :find_all_known_siren


      def init(ctx, **)
        ctx[:fiche_success] = 0
        ctx[:fiche_failure] = 0

        # Setup errors report
        ctx[:errors] = {
          '1' => { nb: 0, error_message: 'Cannot find principal immat' },
          '2' => { nb: 0, error_message: 'Cannot find etablissement principal' }
        }
      end

      def find_siren_with_secondary_immat_only(ctx, **)
        query = "select ds.siren from (select * from dossiers_entreprises where type_inscription = 'S') ds left join (select * from dossiers_entreprises where type_inscription = 'P') dp on ds.siren = dp.siren where dp.siren is null;"

        ctx[:sec_immat_only] = array_of_siren_from_sql_query(query)
      end

      def find_all_known_siren(ctx, sec_immat_only:, **)
        # There are 5_812_698 different siren numbers into database
        # Lets proceed by chunks of 100_000 so 59 iterations to cover
        # all results
        59.times do |i|
          q = query_for_batch(i)
          sirens_chunk = array_of_siren_from_sql_query(q)

          sirens_chunk.each do |siren|
            unless sec_immat_only.include?(siren)
              generate_fiche = Entreprise::Operation::IdentityForCoverRatio.call(siren: siren)
              if generate_fiche.success?
                ctx[:fiche_success] = ctx[:fiche_success] + 1
              else
                ctx[:fiche_failure] = ctx[:fiche_failure] + 1
                occured_error = generate_fiche[:http_error][:app_code]
                ctx[:errors][occured_error][:nb] = ctx[:errors][occured_error][:nb] + 1
              end
            end
          end
        end
      end


      private

      def query_for_batch(offset)
        # Obligation de retourner created_at lorsqu'on l'utilise pour l'ordonnancement
        # Ceci purement pour ordonner la liste des sirens à parcourir par batchs
        "select distinct siren, created_at from dossiers_entreprises order by created_at asc offset #{offset*100000} limit 100000;"
      end

      # Takes a SQL query returning at least a "siren" attribute
      # and returns an array of sirens : ["123456789", ...]
      def array_of_siren_from_sql_query(query)
        # Array of hash : [{ siren: "123456789"}, ...]
        ar_result = ActiveRecord::Base.connection.execute(query).to_a
        result = ar_result.map { |e| e["siren"] }
        result
      end
    end
  end
end
