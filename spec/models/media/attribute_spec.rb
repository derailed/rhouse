require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe Rhouse::Models::Media::Attribute do

  it "should find all music performers correctly" do
    ActiveRecord::Base.with_alternate_connection( "media_test" ) do    
      @artists = Rhouse::Models::Media::Attribute.find_all_artists
      @artists.should_not        be_nil
      @artists.size.should       == 2
      @artists.first.Name.should == "Bob Marley & The Wailers"
      @artists.last.Name.should  == "Daft Punk"
    end
  end

  it "should find all albums for a given performer" do
    ActiveRecord::Base.with_alternate_connection( "media_test" ) do
      artist = Rhouse::Models::Media::Attribute.find_by_Name( "Daft Punk" )      
      albums = artist.find_all_albums
      albums.size.should == 1
      albums.map(&:Name).sort.should == ["Discovery"]
      artist = Rhouse::Models::Media::Attribute.find_by_Name( "Bob Marley & The Wailers" )
      albums = artist.find_all_albums
      albums.size.should == 6
      albums.map(&:Name).sort.should == [ 
        "Burnin'", 
        "Catch a Fire", 
        "Kaya", 
        "Natty Dread", 
        "Rastaman Vibration", 
        "Songs of Freedom"
      ]
    end
  end
  
  it "should find all songs for a given album" do
    ActiveRecord::Base.with_alternate_connection( "media_test" ) do
      artist = Rhouse::Models::Media::Attribute.find_by_Name( "Daft Punk" )      
      songs  = artist.find_all_songs( "Discovery" )
      songs.size.should == 12
      songs.map(&:Name).sort.should == ["Crescendolls", "Digital Love", "Face To Face", "Harder, Better, Faster, Stronger", "High Life", "Night Vision", "One More Time", "Short Cicuit", "Something About Us", "Too Long", "Veridis Quo", "Voyager"]      
      artist = Rhouse::Models::Media::Attribute.find_by_Name( "Bob Marley & The Wailers" )
      songs  = artist.find_all_songs( "Kaya" )
      songs.size.should == 2    
      songs.map(&:Name).should == ["Easy Skanking", "Sun Is Shining"]      
    end    
  end
  
end
