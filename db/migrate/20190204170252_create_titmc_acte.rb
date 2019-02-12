class CreateTitmcActe < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_actes, id: :uuid do |t|
      t.string 'type'
      t.string 'nature'
      t.string 'date_depot'
      t.string 'date_acte'
      t.string 'numero_depot_manuel'
      t.string 'entreprise_id'

      t.timestamps
    end
  end
end
