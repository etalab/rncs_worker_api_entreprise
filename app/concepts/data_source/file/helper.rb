# TODO delete this helper when no more stock files uses this (see PM Import operation)
module DataSource
  module File
    module Helper
      def csv_to_hash(ctx, file_path:, **)
        ::File.open(file_path, 'r:bom|utf-8') { |f| ctx[:raw_data] = SmarterCSV.process(f, { col_sep: ';', remove_empty_values: false }) }
      end
    end
  end
end
