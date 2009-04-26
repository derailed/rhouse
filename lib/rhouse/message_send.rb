require 'socket'
require 'base64'

module Rhouse
  # Manages DCE router connections - provides for sending control commands to
  # various devices
  class MessageSend
    include Socket::Constants

    # Socket to communicate with the router
    attr_reader :out_socket
    
    # Device id for message sender
    def message_send_device_id() -1003; end
    
    # Opens a connection with the dce and send commands to the router. 
    # This call automatically closes out the connection when done.
    def self.send( &block )
      sender = MessageSend.new
      sender.send( :connect )
      yield sender
      sender.send(:close)
    end

    # Sends a plain text message to the dce router
    #   Example send_command( "0 28 1 193" ). Will turn a light off
    #   BOZO !! Will need to handle return parameters and the whole ding dang deal...
    def send_command( command )
      cmd = "MESSAGET #{command.size}\n#{command}\n"
      logger.debug( ">>> Sending cmd #{cmd.gsub( /\n/, ' ' )}" )
      
      out_socket.send( cmd , 0 )
      result = out_socket.recv(100)
      logger.debug( "<<< Result ==> #{result}" )
      result
    end
   
    # =========================================================================
    private
          
      # Load configuration parameters
      def init_config
        unless @config
          logger.debug( "Loading configuration file for `#{Rhouse.environment}" )          
          config  = YAML.load_file( Rhouse.confpath( "rhouse.yml" ) )
          raise "Unable to find config file #{Rhouse.confpath( "rhouse.yml" )}" unless config
          @config = config[Rhouse.environment]
        end
        @config
      end
                  
      # Fetch configuration parameter
      def config( sym )
        init_config[sym.to_s]
      end
    
      # connect to DCE
      def connect
        logger.debug( "Message_Send::Connect host #{config(:host)}:#{config(:port)}" )
        
        @out_socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
        out_socket.connect( Socket.pack_sockaddr_in( config(:port), config(:host) ) )

        # check if router is ready to receive commands
        check_router
                
        out_socket.send( "EVENT #{message_send_device_id}\n", 0 )
        check_ok_response( out_socket, "Checking event channel connection" )
        
        # we'll be sending out plain text messages
        sleep 1        
        logger.debug "Registering for plain text messages"
        out_socket.send( "PLAIN_TEXT\n", 0 )
        check_ok_response( out_socket, "Registering plain text" )
        
        logger.debug "Connection success! Ready to send some shit out..."
      end

      # Checks if router is ready to receive commands for us ?
      def check_router
        # checks if the router is ready for us ?
        out_socket.send( "READY\n", 0 )
        result = out_socket.recv( 100 )
        logger.debug( "RESP TO READY #{result}" )
        raise "The router does not seem ready to receive commands" unless result == "YES\n"        
      end
      
      # Closeout connections
      def close
        logger.debug( "Closing out socket connection..." )
        out_socket.close
      end

      # Checks for ok response from router
      def check_ok_response( socket, msg )
        result = socket.recv( 100 )
        logger.debug( "Result for #{msg} : #{result}" )
        raise "Invalid response for #{msg}" unless result == "OK\n"
      end
      
      def logger
        Rhouse.logger
      end        
  end
end