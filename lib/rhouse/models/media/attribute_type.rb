module Rhouse::Models::Media
  class AttributeType < ActiveRecord::Base
    set_table_name  'AttributeType'
    set_primary_key "PK_#{AttributeType.table_name}"
  end  
end