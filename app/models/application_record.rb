class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.import(batch)
    data_with_timestamps = add_timestamps(batch)
    insert_all!(data_with_timestamps)
  end

  def self.add_timestamps(data)
    now = Time.now
    data.each { |e| e[:created_at] = e[:updated_at] = now }
  end
end
