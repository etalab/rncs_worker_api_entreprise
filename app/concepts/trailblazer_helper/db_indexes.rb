module TrailblazerHelper
  module DBIndexes
    def create_queries(type_greffe)
      queries = []
      for_all_indexes(type_greffe) do |table, index|
        index_name = name_for(table, index)
        index_columns = columns_for(index)
        queries.push("CREATE INDEX IF NOT EXISTS #{index_name} ON #{table} #{index_columns};")
      end

      queries
    end

    def drop_queries(type_greffe)
      queries = []
      for_all_indexes(type_greffe) do |table, index|
        index_name = name_for(table, index)
        queries.push("DROP INDEX IF EXISTS #{index_name};")
      end

      queries
    end


    private

    def configured_indexes
      Rails.application.config_for(:db_indexes)
    end

    def for_all_indexes(type_greffe)
      configured_indexes[type_greffe.to_s].each do |table, indexes|
        indexes.each do |index|
          yield(table, index)
        end
      end
    end

    def name_for(table, index)
      index_name = ''
      if multi_columns?(index)
        index_name = "index_#{table}_#{index.join('_')}"
      else
        index_name = "index_#{table}_#{index}"
      end

      index_name
    end

    def columns_for(index)
      columns = ''
      if multi_columns?(index)
        columns = "(#{index.join(',')})"
      else
        columns = "(#{index})"
      end

      columns
    end

    def multi_columns?(index)
      index.class == Array
    end
  end
end
