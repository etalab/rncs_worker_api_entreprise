class CreateStockUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_units, id: :uuid do |t|
      t.string :code_greffe
      t.integer :number
      t.string :name
      t.string :status
      t.belongs_to :stock, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
