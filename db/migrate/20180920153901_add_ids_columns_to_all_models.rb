class AddIdsColumnsToAllModels < ActiveRecord::Migration[5.2]
  def change
    # Wildly import every models with dossier entreprise key (code_greffe,
    # numero_gestion, siren) and create association links afterwards

    [
      :personnes_morales,
      :personnes_physiques,
      :representants,
      :etablissements,
      :observations,
    ]
      .each do |table|
      change_table table do |t|
        t.string :code_greffe
        t.string :numero_gestion
        t.string :siren
      end
    end
  end
end
