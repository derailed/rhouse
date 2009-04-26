require "sync"

module Rhouse::Extensions
  module AlternateConnections
    
    def self.mutex
      @mutex ||= Sync.new
    end

    module ClassMethods

      # Temporarily set aside the current ActiveRecord connection for this class (ActiveRecord::Base or subclasses)
      # for the duration of the given block.
      def with_alternate_connection( environment, &blk )
        config = YAML.load_file( Rhouse.conf_path( "database.yml" ) )[environment]

        Rhouse::Extensions::AlternateConnections.mutex.synchronize(:EX) do
          begin
            logger.debug "setting connection pool for #{name} aside, replacing with pool for #{environment}"
            backup = connection_handler.connection_pools[name]
            if connection_handler.connection_pools[environment]
              connection_handler.connection_pools[name] = connection_handler.connection_pools[environment]
            else
              establish_connection(config) # puts it in connection_handler.connection_pools[name]
              connection_handler.connection_pools[environment] = connection_handler.connection_pools[name]
            end
            yield
          ensure
            logger.debug "putting connection pool for #{name} back"
            if backup
              connection_handler.connection_pools[name] = backup
            else
              connection_handler.connection_pools.delete name
            end
          end
        end
      end

    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

  end
end

class ActiveRecord::Base

  include Rhouse::Extensions::AlternateConnections

  # cattr_accessor replacements

  def self.connection_handler
    Rhouse::Extensions::AlternateConnections.mutex.synchronize(:SH) do
      @@connection_handler
    end
  end

  def connection_handler
    Rhouse::Extensions::AlternateConnections.mutex.synchronize(:SH) do
      @@connection_handler
    end
  end

  def self.connection_handler=(obj)
    Rhouse::Extensions::AlternateConnections.mutex.synchronize(:SH) do
      @@connection_handler = obj
    end
  end

end
