class Client < ApplicationRecord
  has_many :clients
  validates :name, presence: :true, uniqueness: true
end
