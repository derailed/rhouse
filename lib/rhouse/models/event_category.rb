require 'ostruct'

module Rhouse::Models
  class EventCategory < ActiveRecord::Base
    set_table_name  'EventCategory'
    set_primary_key "PK_#{Device.table_name}"
    
    # relationships...
    belongs_to :parent,
      :foreign_key => "FK_EventCategory", 
      :class_name  => "Rhouse::Models::EventCategory" 
  end
end