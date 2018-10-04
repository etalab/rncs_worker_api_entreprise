class AddProceededToDailyUpdates < ActiveRecord::Migration[5.2]
  def change
    change_table :daily_updates do |t|
      t.boolean :proceeded
    end
  end
end
