require 'ostruct'

module Rhouse::Models
  class Event < ActiveRecord::Base
    set_table_name  'Event'
    set_primary_key "PK_#{Event.table_name}"
  
    # relationships...
    belongs_to :template, 
      :foreign_key => "FK_DeviceTemplate", 
      :class_name  => "Rhouse::Models::DeviceTemplate"
            
    has_many :event_event_parameters,
      :foreign_key => "FK_Event", 
      :class_name  => "Rhouse::Models::EventEventParameter"
    has_many :event_parameters, 
      :through    => :event_event_parameters,
      :source     => :event_parameter,
      :class_name => "Rhouse::Models::EventParameter"
      
      
    # Find all parameters associated with this event
    def parameters
      params = []
      self.event_parameters.each do |param|
        params << OpenStruct.new( :param_id => param.id, :name => param.Description, :param_type => param.parameter_type.Description )
      end
      params
    end      
  end
end