require 'memcached'

module Rhouse
  class MemCache
  
    # fetch data from cache
    def self.cache_get( key )
      mc[ key ]
    end

    # store data in cache
    def self.cache_set( key, value )
      mc.set( key, value, self.expiry_time )
    end
        
    # =========================================================================
    private

      # Default cache expiration
      def self.expiry_time
        24*60*60 # => 24hours
      end        
  
      # Get cache instance
      def self.mc
        @cache ||= ::MemCache.new( 'localhost', options )
      end
  
      # Cache setup options
      def self.options
        {
           :c_threshold => 100_000,
           :compression => true,
           :debug       => false,
           :namespace   => "rh_ws",
           :readonly    => false,
           :urlencode   => false
        }
      end
  end
end  
  
