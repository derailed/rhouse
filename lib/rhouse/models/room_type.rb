module Rhouse::Models
  class RoomType < ActiveRecord::Base
    set_table_name  'RoomType'
    set_primary_key "PK_#{RoomType.table_name}"
  end
end