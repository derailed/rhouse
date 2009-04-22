module Rhouse::Models
  class DeviceData < ActiveRecord::Base
    set_table_name  'DeviceData'
    set_primary_key "PK_#{DeviceData.table_name}"
  
    # relationships...
    belongs_to :parameter_type, 
      :foreign_key => "FK_ParameterType", 
      :class_name  => "Rhouse::Models::ParameterType"
  end
end