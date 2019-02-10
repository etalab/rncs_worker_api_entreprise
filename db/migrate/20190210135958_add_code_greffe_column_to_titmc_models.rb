class AddCodeGreffeColumnToTitmcModels < ActiveRecord::Migration[5.2]
  def change
    [
      :titmc_actes,
      :titmc_adresses,
      :titmc_bilans,
      :titmc_etablissements,
      :titmc_observations,
      :titmc_representants
    ].each do |table|
      change_table table do |t|
        t.string 'code_greffe'
      end
    end
  end
end
