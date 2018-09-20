module DataSource
  module File
    class CSVReader
      def initialize(file, mapping)
        @file = file
        @options = default_options
        add_mapping_to_options(mapping)
      end

      def proceed
        ::File.open(@file, 'r:bom|utf-8') do |f|
          SmarterCSV.process(f, @options) do |batch|
            yield(batch)
          end
        end
      end

      def default_options
        {
          col_sep: ';',
          chunk_size: Rails.configuration.rncs_sources['import_batch_size'],
          remove_empty_hashes: false,
          hash_transformations: :none,
          header_transformations: [:none]
        }
      end

      def add_mapping_to_options(mapping)
        @options[:header_transformations].push({ key_mapping: mapping })
      end
    end
  end
end
