module Rhouse::Models
  class CommandCommandParameter < ActiveRecord::Base
    set_table_name  'Command_CommandParameter'
    set_primary_key "PK_#{CommandCommandParameter.table_name}"
  
    # relationships...
    belongs_to :command, 
      :foreign_key => "FK_Command", 
      :class_name  => "Rhouse::Models::Command"
    belongs_to :command_parameter, 
      :foreign_key => "FK_CommandParameter", 
      :include     => :type,
      :class_name  => "Rhouse::Models::CommandParameter"    
  end
end