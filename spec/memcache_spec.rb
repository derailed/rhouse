require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))
require 'memcache'

describe Rhouse::MemCache do
      
  it "initialize the cache with the correct options" do
    MemCache.should_receive( :new ).with( "localhost", { 
      :debug => false, 
      :c_threshold => 100_000, 
      :compression => true, 
      :namespace => "rh_ws", 
      :urlencode => false, 
      :readonly => false } )
    Rhouse::MemCache.mc    
  end
  
  it "should fetch items from the cache correctly" do
    cache = mock( ::MemCache )
    Rhouse::MemCache.should_receive( :mc ).once.and_return( cache )
    cache.should_receive( '[]' ).once.with( "Fred" )
    Rhouse::MemCache.cache_get( "Fred" )
  end
  
  it "should store items in the cache correctly" do
    cache = mock( ::MemCache )
    Rhouse::MemCache.should_receive( :mc ).once.and_return( cache )
    cache.should_receive( 'set' ).once.with( "Fred", "Blee", 24*60*60 )
    Rhouse::MemCache.cache_set( "Fred", "Blee" )
  end
    
end
