# BOZO !! Handle EK_MediaType
module Rhouse::Models::Media
  class MediaProvider < ActiveRecord::Base
    set_table_name  'MediaProvider'
    set_primary_key "PK_#{MediaProvider.table_name}"
  
    # relationships...
    belongs_to :provider_source, 
      :foreign_key => "FK_ProviderSource", 
      :class_name  => "Rhouse::Models::Media::ProviderSource"
  end
end