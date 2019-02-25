module Files
  module Operation
    class CheckMD5 < Trailblazer::Operation
      step :parse_md5_filename
      step :read_md5_file_hash
      fail :log_md5_file_not_found, fail_fast: true
      step :compute_md5
      fail :log_file_not_found, fail_fast: true
      step :compare
      fail :log_compare_failed
      pass :log_success

      def parse_md5_filename(ctx, path:, **)
        ctx[:md5_filename] = path.gsub /\..*$/, '.md5'
      end

      def read_md5_file_hash(ctx, md5_filename:, **)
        ctx[:expected_md5] = ::File.read(md5_filename).delete("\n")
      rescue Errno::ENOENT
        false
      end

      def compute_md5(ctx, path:, **)
        ctx[:computed_md5] = ::Digest::MD5::file(path).hexdigest
      rescue Errno::ENOENT
        false
      end

      def compare(ctx, computed_md5:, expected_md5:, **)
        computed_md5 == expected_md5
      end

      def log_md5_file_not_found(ctx, logger:, path:, **)
        logger.error "MD5 file not found (#{path})"
      end

      def log_file_not_found(ctx, logger:, path:, **)
        logger.error "File not found (#{path})"
      end

      def log_compare_failed(ctx, logger:, path:, **)
        logger.error "MD5 comparison failed (#{path})"
      end

      def log_success(ctx, logger:, path:, **)
        logger.info "MD5 check success (#{path})"
      end
    end
  end
end
