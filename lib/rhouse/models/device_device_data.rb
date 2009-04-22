module Rhouse::Models
  class DeviceDeviceData < ActiveRecord::Base
    set_table_name  'Device_DeviceData'
    set_primary_key "PK_#{DeviceDeviceData.table_name}"
  
    # relationships...
    belongs_to :device, 
      :foreign_key => "FK_Device", 
      :class_name  => "Rhouse::Models::Device"
    belongs_to :device_data, 
      :foreign_key => "FK_DeviceData", 
      :class_name  => "Rhouse::Models::DeviceData"    
    belongs_to :controlled_by, 
      :foreign_key => "FK_Device_ControlledVia", 
      :class_name  => "Rhouse::Models::Device"
  end
end