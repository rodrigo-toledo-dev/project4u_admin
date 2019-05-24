class Project < ApplicationRecord
  belongs_to :user
  validates :name, :screen_of_records, :screen_of_editions, :screen_of_searchs, :reports, :print_of_documents, :send_of_messages, :automatic_routines, :external_database_tables, presence: true
end
