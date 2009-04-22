module Rhouse::Models
  class Installation < ActiveRecord::Base
    set_table_name  'Installation'
    set_primary_key "PK_#{Installation.table_name}"  
  end
end