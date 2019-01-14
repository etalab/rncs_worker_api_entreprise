module TribunalCommerce
  module DailyUpdate
    module Operation
      class FetchInPipe < Trailblazer::Operation
        extend ClassDependencies

        self[:flux_folder] = ::File.join(Rails.configuration.rncs_sources['path'], 'tc', 'flux')

        step :fetch_updates
        step :deserialize
        fail ->(ctx, flux_folder:, **) { ctx[:error] = "No daily updates found inside #{flux_folder}. Ensure the folder exists with a valid subfolder structure." }


        def fetch_updates(ctx, flux_folder:, **)
          # Flux are located in subfolders following the 'AAAA/MM/DD' pattern
          pattern = ::File.join(flux_folder, '*', '*', '*')
          flux_paths = Dir.glob(pattern)
          ctx[:flux_path_list] = flux_paths unless flux_paths.empty?
        end

        def deserialize(ctx, flux_path_list:, flux_folder:, **)
          daily_updates = flux_path_list.map do |update_path|
            if match = update_path.match(/\A#{flux_folder}\/(.{4})\/(.{2})\/(.{2})\Z/)
              year, month, day = match.captures
              DailyUpdateTribunalCommerce.new(
                year: year,
                month: month,
                day: day,
                files_path: update_path,
                partial_stock: false
              )
            else
              return false
            end
          end

          ctx[:daily_updates] = daily_updates
        end
      end
    end
  end
end
