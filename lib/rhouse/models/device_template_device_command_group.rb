module Rhouse::Models
  class DeviceTemplateDeviceCommandGroup < ActiveRecord::Base
    set_table_name  'DeviceTemplate_DeviceCommandGroup'
    set_primary_key "PK_#{DeviceTemplateDeviceCommandGroup.table_name}"
  
    # relationships...
    belongs_to :device_template, 
      :foreign_key => "FK_DeviceTemplate", 
      :class_name  => "Rhouse::Models::DeviceTemplate"
    belongs_to :device_command_group, 
      :foreign_key => "FK_DeviceCommandGroup", 
      :class_name  => "Rhouse::Models::DeviceCommandGroup"    
  end
end