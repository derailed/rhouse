module Rhouse::Models::Media
  class MediaSubType < ActiveRecord::Base
    set_table_name  'MediaSubType'
    set_primary_key "PK_#{MediaSubType.table_name}"  
  end
end