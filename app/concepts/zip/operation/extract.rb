require 'open3'

module ZIP
  module Operation
    class Extract < Trailblazer::Operation
      step :setup_context
      step :unzip
      fail :log_unzip_failed
      step :fetch_unzip_files

      def setup_context(ctx, path:, **)
        ctx[:filename]       = Pathname.new(path).basename('.zip')
        ctx[:dest_directory] = "#{Rails.root}/tmp/#{ctx[:filename]}"
      end

      def unzip(ctx, path:, dest_directory:, **)
        # -o overrides existing files (removes unix prompt for override)
        _stdout, stderr, status = ::Open3.capture3 "unzip -o #{path} -d #{dest_directory}"

        ctx[:zip_stderr] = stderr
        status.success?
      end

      def log_unzip_failed(ctx, zip_stderr:, **)
        ctx[:error] = zip_stderr
      end

      def fetch_unzip_files(ctx, dest_directory:, **)
        dir_content = Dir.glob("#{dest_directory}/**/*")
        ctx[:extracted_files] = dir_content.select { |e| File.file?(e) }
      end
    end
  end
end
