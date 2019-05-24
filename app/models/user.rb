class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :client
  has_many :projects
  validates :first_name, :last_name, presence: true

  def name
    [first_name.to_s, last_name.to_s].join(' ')
  end
end
