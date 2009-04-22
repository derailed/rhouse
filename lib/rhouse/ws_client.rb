require 'rfuzz/client'
require 'base64'
require 'cgi'

module Rhouse
  # Convenience to connect to rhouse web service and sending commands to the router.
  # This is the preferred way to interact with the router for outside ruby applications.
  # You should always use this class when sending out device control commands.
  class WsClient
    # Initialize the web service client. This call assumes you have already called
    # Rhouse.initialize, prior to sending out commands using the web server.
    # TODO !! Make it static class !!
    def initialize
      raise "Rhouse must be initialized" unless Rhouse.initialized?
      init_config
      Rhouse.logger.info( "Connected to RHouse web service on #{config(:host)}:#{config(:rhouse_port)}" )
    end
      
    # Gets a handle to rhouse web service
    def rhouse_service
      @rhouse_service ||= RFuzz::HttpClient.new( config(:host), config(:rhouse_port) )
    end
      
    # Sends a command to the router. This assumes the following protocol for hash keys:
    # * <tt>:device_id</tt>     The id of the device to send a command to
    # * <tt>:command_id</tt>    The id of the command
    # * <tt>parameter_hash</tt> A Hash of parameters param_id/value associated with the command
    def send_cmd( command_hash )   
      params = command_hash.keys.sort{ |a,b| a.to_s <=> b.to_s }.map{ |k| "#{k}=#{command_hash[k]}" }.join("&")      
      Rhouse.logger.debug( "Sending request #{params.inspect}")
      result = rhouse_service.post( '/cmd', 
        :head => { "Content-type" => "application/x-www-form-urlencoded" },
        :body => params )
      unless result.http_status.index("2") == 0
        text = result.http_reason
        raise "Error querying RHouse service: #{text}"
      end
      Rhouse.logger.debug( "Got Response : '#{result.http_body}'" )
      result.http_body
    rescue Errno::ECONNREFUSED
      raise "Could not connect to RHouse service"        
    end  

    # =========================================================================    
    private
          
      # Load configuration parameters
      def init_config
        unless @config
          Rhouse.logger.debug( "Loading configuration file for `#{Rhouse.environment}" )          
          config  = YAML.load_file( Rhouse.confpath( "rhouse.yml" ) )
          raise "Unable to find config file #{Rhouse.confpath( "rhouse.yml" )}" unless config
          @config = config[Rhouse.environment]
        end
        @config
      end
  
      # fetch configuration parameter
      def config( key )
        @config[key.to_s]
      end
    
  end
end
