module Rhouse::Models
  class DeviceTemplate < ActiveRecord::Base
    set_table_name  'DeviceTemplate'
    set_primary_key "PK_#{DeviceTemplate.table_name}"
  
    # relationships...
    belongs_to :category, 
      :foreign_key => "FK_DeviceCategory", 
      :class_name  => "Rhouse::Models::DeviceCategory"  
      
    has_many :device_template_device_command_groups,
      :foreign_key => "FK_DeviceTemplate", 
      :class_name  => "Rhouse::Models::DeviceTemplateDeviceCommandGroup"    
    has_many :command_groups, 
      :through    => :device_template_device_command_groups,
      :source     => :device_command_group,
      :class_name => "Rhouse::Models::DeviceCommandGroup"

    def DeviceTemplate.lighting_templates
      find( :all, :conditions => [ "FK_DeviceCategory = ?", DeviceCategory.lighting.id ] )
    end

    def DeviceTemplate.ip_cam_templates
      find( :all, :conditions => [ "FK_DeviceCategory = ?", DeviceCategory.ip_cam.id ] )
    end

  end
end