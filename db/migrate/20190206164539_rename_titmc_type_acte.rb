class RenameTitmcTypeActe < ActiveRecord::Migration[5.2]
  def change
    rename_column :titmc_actes, :type, :type_acte
  end
end
