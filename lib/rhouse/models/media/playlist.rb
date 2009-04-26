# BOZO !! Figure out EK_User
module Rhouse::Models::Media
  class Playlist < ActiveRecord::Base
    set_table_name  'Playlist'
    set_primary_key "PK_#{Playlist.table_name}"
  
    # relationships...
    belongs_to :picture, 
      :foreign_key => "FK_Picture", 
      :class_name  => "Rhouse::Models::Media::Picture"
  end
end