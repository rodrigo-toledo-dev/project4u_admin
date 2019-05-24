class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.references :user
      t.string :name, null: false, default: ""
      t.integer :screen_of_records, null: false, default: 0
      t.integer :screen_of_editions, null: false, default: 0
      t.integer :screen_of_searchs, null: false, default: 0
      t.integer :reports, null: false, default: 0
      t.integer :print_of_documents, null: false, default: 0
      t.integer :send_of_messages, null: false, default: 0
      t.integer :automatic_routines, null: false, default: 0
      t.integer :external_database_tables, null: false, default: 0

      t.timestamps
    end
  end
end
