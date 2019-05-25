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

  def self.register(params)
    uuid, gcm_reg_id = params[:uuid], params[:app_gcm_id]
    device = Device.where(uuid: uuid).first
    return device if device
    device.gcm_reg_id = gcm_reg_id
    device.save!
  end
end
