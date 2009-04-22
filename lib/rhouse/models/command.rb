module Rhouse::Models
  class Command < ActiveRecord::Base
    set_table_name  'Command'
    set_primary_key "PK_#{Command.table_name}"
  
    # relationships...
    belongs_to :category, 
      :foreign_key => "FK_CommandCategory", 
      :class_name  => "Rhouse::Models::CommandCategory"
    has_many :command_command_parameters,
      :foreign_key => "FK_Command", 
      :class_name  => "Rhouse::Models::CommandCommandParameter"    
    has_many :command_parameters, 
      :through    => :command_command_parameters,
      :source     => :command_parameter,
      :class_name => "Rhouse::Models::CommandParameter"
      
    # Convenience. Only pick out interesting parts of parameters
    def parameters
      params = []
      self.command_parameters.each do |param|
        params << OpenStruct.new( :param_id => param.id, :name => param.Description, :param_type => param.type.Description )
      end
      params
    end
  end
end