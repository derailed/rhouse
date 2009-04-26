module Rhouse::Models::Media
  class MediaSource < ActiveRecord::Base
    set_table_name  'MediaSource'
    set_primary_key "PK_#{MediaSource.table_name}"  
  end
end