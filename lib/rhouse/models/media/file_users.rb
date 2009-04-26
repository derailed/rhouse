# BOZO !! EK_Users
module Rhouse::Models::Media
  class FileUsers < ActiveRecord::Base
    set_table_name  'FileUsers'
    set_primary_key "PK_#{FileUsers.table_name}"
  
    # relationships...
    belongs_to :file, 
      :foreign_key => "FK_File", 
      :class_name  => "Rhouse::Models::Media::File"
  end
end