module Rhouse::Models
  class CommandCategory < ActiveRecord::Base
    set_table_name  'CommandCategory'
    set_primary_key 'PK_CommandCategory'
  
    # relationships...
    belongs_to :parent, 
      :foreign_key => "FK_CommandCategory_Parent",
      :class_name  => "Rhouse::Models::CommandCategory"      
    has_many :commands  
  end
end