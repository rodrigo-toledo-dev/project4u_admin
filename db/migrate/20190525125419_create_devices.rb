class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.references :user, foreign_key: true
      t.string :uuid
      t.string :gcm_reg_id
      t.string :version

      t.timestamps
    end
  end
end
