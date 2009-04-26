module Rhouse::Models::Media
  class PictureFile < ActiveRecord::Base
    set_table_name  'PictureFile'
    set_primary_key "PK_#{PictureFile.table_name}"
  
    # relationships...
    belongs_to :picture, 
      :foreign_key => "FK_Picture", 
      :class_name  => "Rhouse::Models::Media::Picture"
    
    belongs_to :file, 
      :foreign_key => "FK_File", 
      :class_name  => "Rhouse::Models::Media::File"
  end
end