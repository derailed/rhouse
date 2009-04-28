require 'rubygems'
require 'sinatra'

root_dir = File.dirname( __FILE__ )

set :enviroment, :production
set :root      , root_dir
set :app_file  , File.join( root_dir, %w[bin rh_rhouse] )
disable :run

run Sinatra::Application