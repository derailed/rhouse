# Sets up the Rhouse gem environment. 
# Configures logging, database connection and various paths
module Rhouse 
  # Gem version
  VERSION   = '0.0.3'
  # Root path of rhouse
  PATH      = ::File.expand_path(::File.join(::File.dirname(__FILE__), *%w[..]))
  # Lib path
  LIBPATH   = ::File.join( PATH, "lib" )
  # Configuration path
  CONFPATH  = ::File.join( PATH, "config" )
  
  class << self
    # Holds the rhouse configuration hash
    attr_reader :config
    # Holds the environment the gem is running under
    attr_reader :environment
    
    # The version string for the library.
    def version()   VERSION;  end      
    
    # Helper to find file from the root path
    def path( *args )
      args.empty? ? PATH : ::File.join( PATH, args.flatten )
    end

    # Helper to locate a file in lib directory
    def libpath( *args )  
      args.empty? ? LIBPATH : ::File.join( LIBPATH, args.flatten )
    end

    # Helper to locate a configuration file in the config dir
    def confpath( *args )
      args.empty? ? CONFPATH : ::File.join( CONFPATH, args.flatten )
    end

    # Initializes the gem. Sets up logging and database connections if required 
    def initialize( opts={} )
      @config      = default_config.merge( opts )
      @environment = (config[:environment] || ENV['RH_ENV'] || :test).to_s
      establish_db_connection if @config[:requires_db]
      @initialized = true
    end
    public :initialize
        
    # For testing only !
    def reset
      @logger      = nil
      @config      = nil
      @environment = nil
      @initialized = false
    end
    public :reset
    
    # Is rhouse initialized
    def initialized?() @initialized; end
    
    # Is the gem running in production env?
    def production_env?() environment == 'production'; end
    
    # Is the gem running in test env?
    def test_env?()       environment == 'test'      ; end
  
    # Connects to the pluto database
    def establish_db_connection      
      return if ActiveRecord::Base.connected? || !@environment
      require 'active_record'
      
      database = YAML.load_file( conf_path( "database.yml" ) )
      ActiveRecord::Base.colorize_logging = true
      ActiveRecord::Base.logger = logger # set up the AR logger before connecting
      logger.debug "--- Establishing database connection in '#{@environment.upcase}' environment"             
      ActiveRecord::Base.establish_connection( database[@environment] )
    end

    # Helper to locate a configuration file
    def conf_path( *args )
      @conf_path ||= CONFPATH 
      args.empty? ? @confpath : File.join( @conf_path, *args )
    end      
    
    # Sets up the default configuration env. 
    # By default test env, no db connection and stdout logging 
    def default_config
      {
        :environment       => :test,
        :requires_db       => false,
        :log_level         => :info,
        :log_file          => $stdout,
        :email_alert_level => :error 
      }
    end
    
    # Helper to require all files from a given location
    def require_all_libs_relative_to( fname, dir = nil )
      dir ||= ::File.basename(fname, '.*')
      search_me = ::File.expand_path(
          ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

      Dir.glob(search_me).sort.each do |rb| 
        # puts "[REQ] #{rb}"
        require rb 
      end
    end
          
    # Sets up the rhouse logger. Using the logging gem
    def logger
      return @logger if @logger

      # the logger is initialized before anything else, including the database, so include it here.
      require "logger"
          
      @logger = Rhouse::Logger.new( {
        :log_file          => config[:log_file],
        :log_level         => config[:log_level],
        :email_alerts_to   => config[:email_alerts_to],
        :email_alert_level => config[:email_alert_level],
        :additive          => false
      } )        
    end
    
    # For debuging
    def dump
      logger << "-" * 22 + " RHouse configuration " + "-" * 76 + "\n"
      config.keys.sort{ |a,b| a.to_s <=> b.to_s }.each do |k|
        key   = k.to_s.rjust(20)
        value = config[k]
        if value.blank?
          logger << "#{key} : #{value.inspect.rjust(97," ")}\n" # shows an empty hashes/arrays, nils, etc.
        else
          case value
            when Hash
              logger << "#{key} : #{(value.keys.first.to_s + ": " + value[value.keys.first].inspect).rjust(97,' ')}\n"
              value.keys[1..-1].each { |k| logger << " "*23 + (k.to_s + " : " + value[k].inspect).rjust(97," ") + "\n" }
            else
              logger << "#{key} : #{value.to_s.rjust(97," ")}\n"
            end
        end
      end
      logger << "-" * 120 + "\n"
    end
  end  
  
  require Rhouse.libpath(*%w[core_ext active_record base])
  require Rhouse.libpath(*%w[core_ext active_record connection_adapter])
  
  require_all_libs_relative_to( File.join( File.dirname(__FILE__), %w[rhouse] ) )        
end