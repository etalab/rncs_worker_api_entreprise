class DropTitmcActesBilans < ActiveRecord::Migration[5.2]
  def change
    drop_table :titmc_actes
    drop_table :titmc_bilans
  end
end
