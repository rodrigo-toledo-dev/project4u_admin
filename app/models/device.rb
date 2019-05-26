class Device < ApplicationRecord
  belongs_to :user

  def update_appversion!(appversion)
    if appversion != self.version
      update_attribute(:version, appversion)
    end
  end

  def can_receive_push_notifications?
    not gcm_reg_id.blank?
  end

  def name
    "#{uuid} (versão: #{version || "desconhecida"})"
  end

  def self.register(data, user)
    uuid, gcm_reg_id, version = data[:uuid], data[:gcm_reg_id], data[:version]
    device = Device.where(uuid: uuid).first
    unless device
      device = user.devices.build
      device.uuid = uuid
      device.gcm_reg_id = gcm_reg_id
      device.version = version
      device.save!
    end
    device
  end
end
