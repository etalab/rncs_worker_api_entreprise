require 'open3'
require 'securerandom'

module ZIP
  module Operation
    class Extract < Trailblazer::Operation
      step :setup_context
      step :check_directory_does_not_exist_yet
        fail :log_dir_already_exists
      step :unzip
        fail :log_unzip_failed
      step :fetch_unzip_files

      def setup_context(ctx, path:, **)
        ctx[:filename]       = Pathname.new(path).basename('.zip')
        ctx[:dest_directory] = "#{Rails.root}/tmp/#{ctx[:filename]}_#{SecureRandom.hex(3)}"
      end

      def check_directory_does_not_exist_yet(ctx, dest_directory:, **)
        !Pathname.new(dest_directory).exist?
      end

      def log_dir_already_exists(ctx, **)
        ctx[:error] = 'Destination directory already exists'
      end

      def unzip(ctx, path:, dest_directory:, **)
        _stdout, stderr, status = ::Open3.capture3 "unzip #{path} -d #{dest_directory}"

        ctx[:zip_stderr] = stderr
        status.success?
      end

      def log_unzip_failed(ctx, **)
        ctx[:error] ||= ctx[:zip_stderr]
      end

      def fetch_unzip_files(ctx, dest_directory:, **)
        dir_content = Dir.glob("#{dest_directory}/**/*")
        ctx[:extracted_files] = dir_content.select { |e| File.file?(e) }
      end
    end
  end
end
