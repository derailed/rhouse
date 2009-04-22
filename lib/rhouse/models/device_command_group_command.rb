module Rhouse::Models
  class DeviceCommandGroupCommand < ActiveRecord::Base
    set_table_name  'DeviceCommandGroup_Command'
    set_primary_key "PK_#{DeviceCommandGroupCommand.table_name}"
  
    # relationships...
    belongs_to :command, 
      :foreign_key => "FK_Command", 
      :class_name  => "Rhouse::Models::Command"
    belongs_to :device_command_group, 
      :foreign_key => "FK_DeviceCommandGroup", 
      :class_name  => "Rhouse::Models::DeviceCommandGroup"    
  end
end