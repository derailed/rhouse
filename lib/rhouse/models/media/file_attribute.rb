module Rhouse::Models::Media
  class FileAttribute < ActiveRecord::Base
    set_table_name  'File_Attribute'
    set_primary_key "PK_#{FileAttribute.table_name}"
  
    # relationships...
    belongs_to :file, 
      :foreign_key => "FK_File", 
      :class_name  => "Rhouse::Models::Media::File"
    belongs_to :attribute, 
      :foreign_key => "FK_Attribute", 
      :class_name  => "Rhouse::Models::Media::Attribute"      
  end
end