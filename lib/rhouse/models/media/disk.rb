# BOZO !! EK_MediaType, EK_UserPrivate
module Rhouse::Models::Media
  class Disc < ActiveRecord::Base
    set_table_name  'Disc'
    set_primary_key "PK_#{Disc.table_name}"
  
    # relationships...
    belongs_to :media_sub_type, 
      :foreign_key => "FK_MediaSubType", 
      :class_name  => "Rhouse::Models::Media::MediaSubType"
    belongs_to :file_format, 
      :foreign_key => "FK_FileFormat", 
      :class_name  => "Rhouse::Models::Media::FileFormat"
  end
end