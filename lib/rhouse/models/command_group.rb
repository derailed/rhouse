module Rhouse::Models
  class CommandGroup < ActiveRecord::Base
    set_table_name  'CommandGroup'
    set_primary_key "PK_#{CommandGroup.table_name}"
  
    # relationships...
    belongs_to :array, 
      :foreign_key => "FK_Array", 
      :class_name  => "Rhouse::Models::Array"  
    belongs_to :installation, 
      :foreign_key => "FK_Installation", 
      :class_name  => "Pluto::Installation"
    belongs_to :template, 
      :foreign_key => "FK_Template", 
      :class_name  => "Rhouse::Models::Template"
    belongs_to :icon, 
      :foreign_key => "FK_Icon", 
      :class_name  => "Rhouse::Models::Icon"
    belongs_to :design_object, 
      :foreign_key => "FK_DesignObject", 
      :class_name  => "Rhouse::Models::DesignObject"
    belongs_to :orbiter, 
      :foreign_key => "FK_CriteriaOrbiter", 
      :class_name  => "Rhouse::Models::CriteriaOrbiter"
    has_and_belongs_to_many :commands, 
      :class_name              => "Rhouse::Models::Command", 
      :association_foreign_key => "FK_Command", 
      :foreign_key             => "FK_CommandGroup",
      :join_table              => "CommandGroup_Command"
      
  end
end