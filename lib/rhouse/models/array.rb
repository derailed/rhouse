module Rhouse::Models
  class Array < ActiveRecord::Base
    set_table_name  'Array'
    set_primary_key "PK_#{Array.table_name}"
  
    # relationships...
    belongs_to :parent, 
      :foreign_key => "FK_Array_Parent", 
      :class_name  => "Rh::Puto::Models::Array"
  end
end