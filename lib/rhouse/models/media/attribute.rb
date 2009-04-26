module Rhouse::Models::Media
  class Attribute < ActiveRecord::Base
    set_table_name  'Attribute'
    set_primary_key "PK_#{Attribute.table_name}"
  
    # relationships...
    belongs_to :attribute_type, 
      :foreign_key => "FK_AttributeType", 
      :class_name  => "Rhouse::Models::Media::AttributeType"

    has_many :file_attributes,
      :foreign_key => "FK_Attribute",
      :class_name  => "Rhouse::Models::Media::FileAttribute"    
    has_many :files, 
      :through    => :file_attributes,
      :source     => :file,
      :class_name => "Rhouse::Models::Media::File"
    
    # Find all artists  
    def self.find_all_artists 
      @artists   = []
      type       = Rhouse::Models::Media::AttributeType.find_by_Description( 'Performer' )
      performers = find( :all, 
        :conditions => ['FK_AttributeType = ?', type.id],
        :include    => [:files],
        :order      => 'Name Asc' )
      # Check for valid media
      performers.each do |performer|
        @artists << performer unless performer.files.empty?
      end
      @artists
    end
    
    # Finds all albums for this artist
    def find_all_albums
      @albums  = []
      type     = Rhouse::Models::Media::AttributeType.find_by_Description( 'Album' )
      self.files.each do |file|
        file.tags.each do |tag|
          @albums << tag if tag.attribute_type == type and !@albums.include?( tag )
        end
      end
      @albums
    end
    
    def find_all_songs( album_name )
      @songs = []
      type   = Rhouse::Models::Media::AttributeType.find_by_Description( 'Title' )      
      self.files.each do |file|
        tags = file.tags
        if check_for_correct_album( tags, album_name )
          tags.each do |tag|
            @songs << tag if tag.attribute_type == type and !@songs.include?( tag )
          end
        end
      end
      @songs
    end
    
    # =========================================================================
    private
    
      def check_for_correct_album( file_tags, album_name )
        album_type = Rhouse::Models::Media::AttributeType.find_by_Description( 'Album' )
        file_tags.each do |tag|
          return true if tag.attribute_type == album_type and tag.Name == album_name
        end
        false
      end
  end
end