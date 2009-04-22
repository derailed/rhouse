module Rhouse::Models
  class Room < ActiveRecord::Base
    set_table_name  'Room'
    set_primary_key "PK_#{Room.table_name}"
  
    # relationships...
    belongs_to :installation,
      :foreign_key => "FK_Installation",
      :class_name  => "Rhouse::Models::Installation"
    belongs_to :type,
      :foreign_key => "FK_RoomType",
      :class_name  => "Rhouse::Models::RoomType"
    belongs_to :icon,
      :foreign_key => "FK_Icon",
      :class_name  => "Rhouse::Models::Icon"
    belongs_to :floor_plan_object_type,
      :foreign_key => "FK_Icon",
      :class_name  => "Rhouse::Models::Icon"
  end
end