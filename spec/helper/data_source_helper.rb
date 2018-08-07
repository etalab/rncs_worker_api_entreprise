module DataSourceHelper
  # TODO Refactor this by extracting the call to SmarterCSV
  class CSVExtractor < Trailblazer::Operation
    include DataSource::File::Helper

    step :csv_to_hash
  end

  # TODO externalize this configuration
  def labels
    @labels ||= {
      pm_stock_file: {
        path: Rails.root.join('spec/data_source_example/tc/stock/2017/05/04/csv_files_example/0101_S1_20170504_1_PM.csv'),
        deserializer: DataSource::File::PM::Operation::Deserialize
      }
    }
  end

  def path_for(file_label)
    labels.fetch(file_label)[:path]
  end

  def deserializer_for(file_label)
    labels.fetch(file_label)[:deserializer]
  end

  def extract_raw_data(file_label)
    extract_raw_data = CSVExtractor.call(file_path: path_for(:pm_stock_file))
    raw_data = extract_raw_data[:raw_data]
    raw_data # TODO deal with potential errors
  end

  def deserialize_data_from(file_label)
    raw_data = extract_raw_data(file_label)
    deserializer = deserializer_for(file_label)

    deserialize = deserializer.call(raw_data: raw_data)
    deserialize[:raw_data]
  end

  def deserialize_first_line_data_for(file_label)
    data = deserialize_data_from(file_label)
    data[0]
  end

  def first_line_raw_data_for(file_label)
    raw_data = extract_raw_data(file_label)
    raw_data[0]
  end
end
