require File.join( File.dirname(__FILE__), %w[.. spec_helper] ) 

describe Rhouse::Helpers::Audio do
    
  it "should find an album cover correctly" do
    @album_id = 0
    ActiveRecord::Base.with_alternate_connection( "media_test" ) do
      @album_id = Rhouse::Models::Media::Attribute.find_by_Name( "Discovery" ).id
    end        
    Rhouse::Helpers::Audio.should_receive( :media_info ).with( "/home/public/data/audio/Daft Punk/Discovery/01 One More Time.mp3", false ).and_return( { :cover => "Blee" } )
    cover = Rhouse::Helpers::Audio.find_album_cover( @album_id )
    cover.should_not be_nil
  end
    
  it "should pull song meta correctly" do
    info = Rhouse::Helpers::Audio.media_info( File.join( File.dirname(__FILE__), %w[.. .. test music], "song_x.mp3" ) )
    info[:album].should     == "Saint Germain Lounge Rendez Vous Disc 2"
    info[:artist].should    == "A Guy Called Gerald"
    info[:title].should     == "Humanity (Ashley Beedles Love & Compassion Mix)"    
    info[:cover].should     be_nil
  end
  
  it "should load its configuration correctly" do
    Rhouse::Helpers::Audio.config.should_not be_nil
    Rhouse::Helpers::Audio.config['music_depot'].should == '../test/music'
  end
    
end