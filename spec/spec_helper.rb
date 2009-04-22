require 'rubygems'
require 'spec'

path = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift path unless $:.include? path

require 'rhouse'

Rhouse.initialize( 
  :environment => :test, 
  :requires_db => true, 
  :log_level   => :info )