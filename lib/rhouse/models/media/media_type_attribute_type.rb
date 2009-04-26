# BOZO !! Handle EK_MediaType
module Rhouse::Models::Media
  class MediaTypeAttributeType < ActiveRecord::Base
    set_table_name  'MediaType_AttributeType'
    set_primary_key "PK_#{MediaTypeAttributeType.table_name}"
  
    # relationships...
    belongs_to :attribute_type, 
      :foreign_key => "FK_AttributeType", 
      :class_name  => "Rhouse::Models::Media::AttributeType"
  end
end