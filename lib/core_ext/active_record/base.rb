# Our basic framework for extentions to ActiveRecord.  See the individual classes in
# the active_record module for details.
require 'active_record'

module Rhouse
  module CoreExt
    module ActiveRecord
      module ClassMethods; end
      module InstanceMethods; end
    end
  end
end

# Automagically include all the extensions.
Dir.foreach File.dirname(__FILE__) + '/extensions' do |file|
  next unless File.extname(file) == ".rb"
  fname = File.join( File.dirname( __FILE__ ), 'extensions', file )
  require fname if File.file?( fname )
end

# Above will build up InstanceMethods and ClassMethods; this include them in the code once.
ActiveRecord::Base.send :extend , Rhouse::CoreExt::ActiveRecord::ClassMethods
ActiveRecord::Base.send :include, Rhouse::CoreExt::ActiveRecord::InstanceMethods
