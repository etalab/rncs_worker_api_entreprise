module DataSource
  module File
    module Obs
      module Operation
        class Deserialize < Trailblazer::Operation
          step :rework_keys

          def rework_keys(ctx, raw_data:, **)
            raw_data.map! do |e|
              e[:numero] = e.delete(:numéro_observation)
              e[:date_derniere_modification] = e.delete(:date_greffe)

              e
            end
          end
        end
      end
    end
  end
end
