require 'id3lib'

module Rhouse::Helpers
  class Audio
       
    # Retrieves media information by parsing ID tag
    def self.media_info( file, shallow=true )
      return nil unless File.exists?( file )
      tag  = ID3Lib::Tag.new( file )
      { 
        :uri    => file,
        :artist => tag.artist,
        :album  => tag.album,
        :title  => tag.title,
        :cover  => (tag.frame(:APIC) and !shallow) ? tag.frame(:APIC)[:data] : nil
      }
    end

    # Locate artwork for an album
    def self.find_album_cover( album_id )
      ActiveRecord::Base.with_alternate_connection( "media_#{Rhouse.environment}" ) do      
        album = Rhouse::Models::Media::Attribute.find( album_id )
        album.files.sort{ |a,b| a.Filename <=> b.Filename }.each do |file|
          uri       = File.join( file.Path, file.Filename )
          full_info = media_info( uri, false )
          return full_info[:cover] if full_info[:cover] 
        end
      end
      nil
    end
    
    # =========================================================================
    private 
    
      # Fetch music lib configuration based on environment 
      def self.config
        unless @config      
          media_conf = YAML.load_file( Rhouse.confpath( 'media.yml' ) )      
          @config    = media_conf[Rhouse.environment]
        end
        @config
      end    
  end
end