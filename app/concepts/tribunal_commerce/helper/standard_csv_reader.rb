module TribunalCommerce
  module Helper
    class StandardCSVReader
      attr_reader :file, :options, :headers_mapping

      def initialize(file, mapping, keep_nil:false, **)
        @file = file
        @options = default_options
        @headers_mapping = mapping
        @keep_nil = keep_nil
      end

      def line_processing
        proceed do |chunk|
          chunk.each { |row| yield(row) }
        end
      end

      def bulk_processing
        proceed(batch_size: chunk_size) { |batch| yield(batch) }
      end


      private

      def proceed(batch_size:1, **)
        reading_csv_file(file) do |csv_enum|
          handle_csv_by_batch(csv_enum, batch_size) { |batch| yield(batch) }
        end
      end

      def reading_csv_file(file_path)
        ::File.open(file_path, 'r:bom|utf-8') do |f|
          csv = CSV.new(f, options)
          yield(csv)
        end
      end

      def handle_csv_by_batch(csv, batch_size)
        csv.each_slice(batch_size) do |array_of_csv_row|
          array_of_hash = from_csv_row_class_to_hash(array_of_csv_row)
          remove_nil_values(array_of_hash) unless keep_nil?
          yield(array_of_hash)
        end
      end

      def from_csv_row_class_to_hash(csv)
        csv.map do |csv_row|
          discard_values_from_header_mapped_to_nil(csv_row)
          csv_row.to_hash
        end
      end

      def discard_values_from_header_mapped_to_nil(csv_row)
        csv_row.delete_if { |k, v| k.nil? }
      end

      def remove_nil_values(array_of_hash)
        array_of_hash.map! do |row_hash|
          row_hash.reject { |_, v| v.nil? }
        end
      end

      def default_options
        {
          col_sep: ';',
          headers: true,
          converters: [strip_data],
          header_converters: [harmonize_headers]
        }
      end

      def chunk_size
        Rails.configuration.rncs_sources['import_batch_size']
      end

      def harmonize_headers
        Proc.new do |header|
          header.then { |it| it.downcase }
            .then { |it| it.strip }
            .then { |it| it.gsub(/\./, '') }
            .then { |it| it.gsub(/\s|-/, '_') }
            .then { |it| I18n.transliterate(it) }
            .then { |it| it.to_sym }
            .then { |it| map_header(it) }
        end
      end

      def strip_data
        ->(value) { value.strip unless value.nil? }
      end

      def map_header(h)
        headers_mapping.has_key?(h) ? headers_mapping[h] : h
      end

      def keep_nil?
        @keep_nil
      end
    end
  end
end
