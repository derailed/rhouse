module Rhouse::Models
  class FloorPlanType < ActiveRecord::Base
    set_table_name  'FloorPlanType'
    set_primary_key "PK_#{FloorPlanType.table_name}"  
  end
end