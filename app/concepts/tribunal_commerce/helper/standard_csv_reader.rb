module TribunalCommerce
  module Helper
    class StandardCSVReader
      attr_reader :file, :options

      def initialize(file, mapping, keep_nil:false, **)
        @file = file
        @options = default_options
        add_mapping_to_options(mapping)
      end

      def line_processing
        proceed do |chunk|
          chunk.each { |row| yield(row) }
        end
      end

      def bulk_processing
        proceed { |batch| yield(batch) }
      end

      def proceed
        ::File.open(file, 'r:bom|utf-8') do |f|
          SmarterCSV.process(f, options) { |batch| yield(batch) }
        end
      end

      def default_options
        {
          col_sep: ';',
          chunk_size: Rails.configuration.rncs_sources['import_batch_size'],
          header_transformations: [:none, harmonize_headers],
          hash_transformations: [:none]
        }
      end

      def add_mapping_to_options(mapping)
        @options[:header_transformations].push({ key_mapping: mapping })
      end

      def harmonize_headers
        Proc.new do |headers|
          headers.map do |h|
            h.then { |it| it.downcase }
             .then { |it| it.gsub(/\./, '') }
             .then { |it| it.gsub(/\s|-/, '_') }
             .then { |it| I18n.transliterate(it) }
             .then { |it| it.to_sym }
          end
        end
      end
    end
  end
end
