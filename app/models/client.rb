class Client < ApplicationRecord
  validates :name, presence: :true, uniqueness: true
end
