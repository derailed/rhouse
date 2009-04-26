module Rhouse::Models::Media
  class PlaylistEntry < ActiveRecord::Base
    set_table_name  'PlaylistEntry'
    set_primary_key "PK_#{PlaylistEntry.table_name}"
  
    # relationships...
    belongs_to :playlist, 
      :foreign_key => "FK_Playlist", 
      :class_name  => "Rhouse::Models::Media::Playlist"
    belongs_to :file, 
      :foreign_key => "FK_File", 
      :class_name  => "Rhouse::Models::Media::File"
    belongs_to :bookmark, 
      :foreign_key => "FK_Bookmark", 
      :class_name  => "Rhouse::Models::Media::Bookmark"

  end
end