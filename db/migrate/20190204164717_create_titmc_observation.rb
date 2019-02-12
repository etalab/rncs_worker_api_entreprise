class CreateTitmcObservation < ActiveRecord::Migration[5.2]
  def change
    create_table :titmc_observations, id: :uuid do |t|
      t.string 'code'
      t.text 'texte'
      t.string 'date'
      t.string 'numero'
      t.string 'entreprise_id'

      t.timestamps
    end
  end
end
