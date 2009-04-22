module Rhouse::Models
  class EventParameter < ActiveRecord::Base
    set_table_name  'EventParameter'
    set_primary_key "PK_#{EventParameter.table_name}"
  
    # relationships...
    belongs_to :parameter_type, 
      :foreign_key => "FK_ParameterType", 
      :class_name  => "Rhouse::Models::ParameterType"
  end
end