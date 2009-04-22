module Rhouse::Models
  class DeviceObject < ActiveRecord::Base
    set_table_name  'DeviceObject'
    set_primary_key "PK_#{DeviceObject.table_name}"
  end
end