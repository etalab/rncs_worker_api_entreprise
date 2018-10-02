class CreateDaylyUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :dayly_updates, id: :uuid do |t|
      t.string :type
      t.string :year
      t.string :month
      t.string :day
      t.string :files_path

      t.timestamps
    end
  end
end
