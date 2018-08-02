module DataSourceHelper
  def labels
    @labels ||= {
      pm_stock_file: Rails.root.join('spec/data_source_example/tc/stock/2017/05/04/csv_files_example/0101_S1_20170504_1_PM.csv')
    }
  end

  def path_for(file_label)
    labels[file_label]
  end
end
