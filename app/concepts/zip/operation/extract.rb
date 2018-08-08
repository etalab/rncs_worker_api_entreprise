module ZIP
  module Operation
    class Extract < Trailblazer::Operation
      step :unzip
      step :fetch_unzip_files

      def unzip(ctx, path:, **)
        file_name = archive_name(path)
        unzip_directory = "#{Rails.root}/tmp/#{file_name}"

        `unzip #{path} -d #{unzip_directory}`
        ctx[:dest_directory] = unzip_directory
      end

      def fetch_unzip_files(ctx, dest_directory:, **)
        dir_content = Dir.glob("#{dest_directory}/**/*")
        ctx[:extracted_files] = dir_content.select { |e| File.file?(e) }
      end

      private

      def archive_name(file_path)
        file_path.to_s.split('/').last.chomp('.zip')
      end
    end
  end
end
