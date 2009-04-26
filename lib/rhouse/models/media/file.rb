# TODO !! Figure out how to handle cross db relationship ie EK_MediaType, EK_Device...
module Rhouse::Models::Media
  class File < ActiveRecord::Base
    set_table_name  'File'
    set_primary_key "PK_#{File.table_name}"
  
    # relationships...
    belongs_to :media_sub_type, 
      :foreign_key => "FK_MediaSubType",
      :class_name  => "Rhouse::Media::MediaSubType"

    belongs_to :file_format, 
      :foreign_key => "FK_FileFormat",
      :class_name  => "Rhouse::Models::Media::FileFormat"

    belongs_to :file_group, 
      :foreign_key => "FK_FileGroup",
      :class_name  => "Rhouse::Models::Media::FileGroup"

    has_many :file_attributes,
      :foreign_key => "FK_File",
      :class_name  => "Rhouse::Models::Media::FileAttribute"
    has_many :tags, 
      :through    => :file_attributes,
      :source     => :attribute,
      :include    => :attribute_type,
      :class_name => "Rhouse::Models::Media::Attribute"
  end
end