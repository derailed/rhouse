# BOZO !! Handle EK_MediaType, EK_User
module Rhouse::Models::Media
  class Bookmark < ActiveRecord::Base
    set_table_name  'Bookmark'
    set_primary_key "PK_#{Bookmark.table_name}"
  
    # relationships...
    belongs_to :file, 
      :foreign_key => "FK_File", 
      :class_name  => "Rhouse::Models::Media::File"
    belongs_to :disk, 
      :foreign_key => "FK_Disk", 
      :class_name  => "Rhouse::Models::Media::Disc"
    belongs_to :playlist, 
      :foreign_key => "FK_Playlist", 
      :class_name  => "Rhouse::Models::Media::Playlist"
    belongs_to :media_provider, 
      :foreign_key => "FK_MediaProvider", 
      :class_name  => "Rhouse::Models::Media::MediaProvider"
    belongs_to :picture, 
      :foreign_key => "FK_Picture", 
      :class_name  => "Rhouse::Models::Media::Picture"
  end
end