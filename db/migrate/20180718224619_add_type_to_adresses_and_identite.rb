class AddTypeToAdressesAndIdentite < ActiveRecord::Migration[5.2]
  def change
    change_table :adresses do |t|
      t.string :type
    end

    change_table :identites do |t|
      t.string :type
    end
  end
end
