module Rhouse::Models
  class Template < ActiveRecord::Base
    set_table_name  'Template'
    set_primary_key "PK_#{Template.table_name}"  
  end
end