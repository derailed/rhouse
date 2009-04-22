module Rhouse::Models
  class ParameterType < ActiveRecord::Base
    set_table_name  "ParameterType"
    set_primary_key "PK_#{ParameterType.table_name}"
  
    # relationships...
    has_many :command_parameters, 
      :class_name  => 'Rhouse::Models::CommandParameter', 
      :foreign_key => "FK_ParameterType"
    has_many :event_parameters,
      :class_name  => 'Rhouse::Models::EventParameter', 
      :foreign_key => "FK_ParameterType"    
  end
end