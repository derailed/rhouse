module Rhouse::Models::Media
  class FileGroup < ActiveRecord::Base
    set_table_name  'FileGroup'
    set_primary_key "PK_#{FileGroup.table_name}"
  
    # relationships...
    belongs_to :attribute_type, 
      :foreign_key => "FK_AttributeType", 
      :class_name  => "Rhouse::Models::Media::AttributeType"
  end
end