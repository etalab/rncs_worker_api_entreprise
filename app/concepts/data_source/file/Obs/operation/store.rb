module DataSource
  module File
    module Obs
      module Operation
        class Store < Trailblazer::Operation
          include DataSource::File::Helper

          step :csv_to_hash
          step :rework_keys
          step :insert_into_database

          def rework_keys(ctx, data:, **)
            data.map! do |e|
              e[:numero] = e.delete(:numéro_observation)
              e[:date_derniere_modification] = e.delete(:date_greffe)

              e
            end
          end

          def insert_into_database(ctx, data:, **)
            data.each do |row|
              create_observation = Observation::Operation::Create.call(params: row)
            end
          end
        end
      end
    end
  end
end
