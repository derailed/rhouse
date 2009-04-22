module Rhouse::Models
  class EventEventParameter < ActiveRecord::Base
    set_table_name  'Event_EventParameter'
    set_primary_key "PK_#{EventEventParameter.table_name}"
  
    # relationships...
    belongs_to :event, 
      :foreign_key => "FK_Event", 
      :class_name  => "Rhouse::Models::Event"
    belongs_to :event_parameter, 
      :foreign_key => "FK_EventParameter", 
      :class_name  => "Rhouse::Models::EventParameter"    
  end
end