module Rhouse::Models::Media
  class FileFormat < ActiveRecord::Base
    set_table_name  'FileFormat'
    set_primary_key "PK_#{FileFormat.table_name}"
  end
end