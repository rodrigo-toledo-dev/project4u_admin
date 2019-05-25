class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :token_authenticatable
  belongs_to :client
  has_one :device
  has_many :devices
  has_many :projects
  validates :first_name, :last_name, presence: true

  def name
    [first_name.to_s, last_name.to_s].join(' ')
  end

  def api_attributes
    {
      auth_token: authentication_token
    }
  end

  def has_device?
    !device.blank?
  end

  def subscribe!(app_name, device_uuid)
    device = Device.where(uuid: device_uuid).first
    device.user = self
    device.save!
  end
end
