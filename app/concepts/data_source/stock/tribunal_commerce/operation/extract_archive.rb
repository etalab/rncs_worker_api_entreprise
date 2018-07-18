module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class ExtractArchive < Trailblazer::Operation
          step :unzip


          def unzip(ctx, archive_path:, **)
            archive_name = name_from_path(archive_path)
            dest_path = "#{Rails.root}/tmp/#{archive_name}"

            `unzip #{archive_path} -d #{dest_path}`
            ctx[:extracted_files] = Dir.glob("#{dest_path}/*.csv")
          end

          def name_from_path(path)
            path.split('/').last.chomp('.zip')
          end
        end
      end
    end
  end
end
