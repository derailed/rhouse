module Rhouse::Models
  class DeviceCommandGroup < ActiveRecord::Base
    set_table_name  'DeviceCommandGroup'
    set_primary_key "PK_#{DeviceCommandGroup.table_name}"
  
    # relationships...
    belongs_to :category, 
      :foreign_key => "FK_DeviceCategory", 
      :class_name  => "Rhouse::Models::DeviceCategory"
    has_many :device_command_group_commands,
      :foreign_key => "FK_DeviceCommandGroup", 
      :class_name  => "Rhouse::Models::DeviceCommandGroupCommand"    
    has_many :command_group_commands, 
      :through    => :device_command_group_commands,
      :source     => :command,
      :class_name => "Rhouse::Models::Command"      
  end
end