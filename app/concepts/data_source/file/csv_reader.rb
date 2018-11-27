module DataSource
  module File
    class CSVReader
      def self.bulk_processing(file, header_mapping)
        reader = new(file, header_mapping)
        reader.proceed do |batch|
          yield(batch)
        end
      end

      def self.line_processing(file, header_mapping)
        reader = new(file, header_mapping)
        reader.proceed do |batch|
          batch.each do |line|
            yield(line)
          end
        end
      end


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
          col_sep: ',',
          chunk_size: Rails.configuration.rncs_sources['import_batch_size'],
          hash_transformations: [:none],
          header_transformations: [:none]
        }
      end

      def add_mapping_to_options(mapping)
        @options[:header_transformations].push({ key_mapping: mapping })
      end
    end
  end
end
