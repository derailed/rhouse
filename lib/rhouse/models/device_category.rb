module Rhouse::Models
  class DeviceCategory < ActiveRecord::Base
    set_table_name  'DeviceCategory'
    set_primary_key "PK_#{DeviceCategory.table_name}"
    
    def DeviceCategory.lighting
      find( :first, :conditions => ["Description = ?", "Lighting Device"] )
    end
    
    def DeviceCategory.ip_cam
      find( :first, :conditions => ["Description = ?", "IP Cameras"] )
    end    
    
  end
end