module Rhouse::Models
  class CriteriaOrbiter < ActiveRecord::Base
    set_table_name  'CriteriaOrbiter'
    set_primary_key "PK_#{CriteriaOrbiter.table_name}"
  
    # relationships...
    belongs_to :category, 
      :foreign_key => "FK_CommandCategory", 
      :class_name  => "Rhouse::Models::CommandCategory"
    has_and_belongs_to_many :parameters, 
      :class_name              => "Rhouse::Models::CommandParameter", 
      :association_foreign_key => "FK_CommandParameter", 
      :foreign_key             => "FK_Command",
      :join_table              => "Command_CommandParameter"

  end
end