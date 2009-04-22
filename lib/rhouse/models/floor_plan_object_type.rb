module Rhouse::Models
  class FloorPlanObjectType < ActiveRecord::Base
    set_table_name  'FloorPlanObjectType'
    set_primary_key "PK_#{FloorPlanObjectType.table_name}"
  
    # relationships...
    belongs_to :floor_plan, 
      :foreign_key => "FK_FloorPlanType", 
      :class_name  => "Rhouse::Models::FloorPlanType"
  end
end