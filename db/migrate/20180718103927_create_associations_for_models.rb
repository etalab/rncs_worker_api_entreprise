class CreateAssociationsForModels < ActiveRecord::Migration[5.2]
  def change
    change_table :etablissements do |t|
      t.belongs_to :entreprise, type: :uuid, foreign_key: true
    end

    change_table :personnes_physiques do |t|
      t.belongs_to :entreprise, type: :uuid, foreign_key: true
    end

    change_table :observations do |t|
      t.belongs_to :entreprise, type: :uuid, foreign_key: true
    end

    change_table :representants do |t|
      t.belongs_to :entreprise, type: :uuid, foreign_key: true
    end

    change_table :adresses do |t|
      t.belongs_to :addressable, polymorphic: true, type: :uuid
    end

    change_table :identites do |t|
      t.belongs_to :identifiable, polymorphic: true, type: :uuid
    end
  end
end
