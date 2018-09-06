class RemoveAllForeignKeys < ActiveRecord::Migration[5.2]
  def change
    # remove foreign key constraints to improve import speed
    remove_foreign_key :personnes_morales, column: :entreprise_id
    remove_foreign_key :personnes_physiques, column: :entreprise_id
    remove_foreign_key :representants, column: :entreprise_id
    remove_foreign_key :etablissements, column: :entreprise_id
    remove_foreign_key :observations, column: :entreprise_id

    remove_index :representants,       name: 'index_representants_on_entreprise_id'
    remove_index :personnes_physiques, name: 'index_personnes_physiques_on_entreprise_id'
    remove_index :personnes_morales,   name: 'index_personnes_morales_on_entreprise_id'
    remove_index :observations,   name: 'index_observations_on_entreprise_id'
    remove_index :etablissements,   name: 'index_etablissements_on_entreprise_id'
    remove_index :entreprise,   name: 'index_entreprises_on_numero_gestion'
  end
end
