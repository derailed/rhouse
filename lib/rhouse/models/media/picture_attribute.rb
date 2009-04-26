module Rhouse::Models::Media
  class PictureAttribute < ActiveRecord::Base
    set_table_name  'PictureAttribute'
    set_primary_key "PK_#{PictureAttribute.table_name}"
  
    # relationships...
    belongs_to :picture, 
      :foreign_key => "FK_Picture", 
      :class_name  => "Rhouse::Models::Media::Picture"
    
    belongs_to :attribute, 
      :foreign_key => "FK_Attribute", 
      :class_name  => "Rhouse::Models::Media::Attribute"
  end
end