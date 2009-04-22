module Rhouse::Models
  class CommandParameter < ActiveRecord::Base
    set_table_name  "CommandParameter"
    set_primary_key "PK_#{CommandParameter.table_name}"
  
    # relationships...
    belongs_to :type, 
      :foreign_key => "FK_ParameterType", 
      :class_name  => "Rhouse::Models::ParameterType"
    has_and_belongs_to_many :commands, 
      :class_name              => "Rhouse::Models::Command", 
      :association_foreign_key => "FK_Command", 
      :foreign_key             => "FK_CommandParameter",
      :join_table              => "Command_CommandParameter"
  
  end
end