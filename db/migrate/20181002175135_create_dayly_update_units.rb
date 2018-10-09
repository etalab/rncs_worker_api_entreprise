class CreateDaylyUpdateUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :dayly_update_units, id: :uuid do |t|
      t.string :code_greffe
      t.integer :num_transmission
      t.string :files_path
      t.string :status
      t.belongs_to :dayly_update, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
