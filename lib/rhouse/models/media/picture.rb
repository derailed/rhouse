module Rhouse::Models::Media
  class Picture < ActiveRecord::Base
    set_table_name  'Picture'
    set_primary_key "PK_#{Picture.table_name}"  
  end
end