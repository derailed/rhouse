require 'ostruct'

module Rhouse::Models
  class Device < ActiveRecord::Base
    set_table_name  'Device'
    set_primary_key "PK_#{Device.table_name}"
  
    # relationships...
    belongs_to :template, 
      :foreign_key => "FK_DeviceTemplate", 
      :class_name  => "Rhouse::Models::DeviceTemplate"
    belongs_to :room, 
      :foreign_key => "FK_Room", 
      :class_name  => "Rhouse::Models::Room"    
    belongs_to :controlled_by, 
      :foreign_key => "FK_Device_ControlledVia", 
      :class_name  => "Rhouse::Models::Device"    
    has_many :device_device_data,
      :foreign_key => "FK_Device", 
      :class_name  => "Rhouse::Models::DeviceDeviceData"        
    has_many :device_data, 
      :through    => :device_device_data,
      :source     => :device_data,
      :class_name => "Rhouse::Models::DeviceData"
      
    def Device.all_lights
      find( :all, :conditions => [ "FK_DeviceTemplate in ( ? )", DeviceTemplate.lighting_templates.map(&:id) ] )
    end
    
    def Device.all_ip_cams
      find( :all, :conditions => [ "FK_DeviceTemplate in ( ? )", DeviceTemplate.ip_cam_templates.map(&:id) ] )
    end
        
    # find a command by name
    def find_command( name )
      commands.each { |cmd| return cmd if cmd.name == name }
      nil
    end
    
    # Find a command parameter by name for a given command
    def find_parameter( command, param_name )
      command.params.each { |param| return param if param.name == param_name }
      nil
    end
    
    # find all available commands and associated params for this device
    def commands
      cmds = []
      command_groups = self.template.command_groups
      command_groups.each do |c|
        commands = c.command_group_commands
        commands.each do |cmd|
          cmds << OpenStruct.new( :cmd_id => cmd.id, :name => cmd.Description, :params => cmd.parameters )
        end
      end
      cmds
    end
    
  end
end