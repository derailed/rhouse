module Rhouse::Models
  class Icon < ActiveRecord::Base
    set_table_name  'Icon'
    set_primary_key "PK_#{Icon.table_name}"  
  end
end