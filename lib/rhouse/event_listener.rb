require 'socket'
require 'beanstalk-client'

module Rhouse
  # Connects to DCE router and register interceptor to receive certain events.
  # Events registration is specified in the config yml file. Once an event is
  # detected is will be put on beanstalk queue for workers consumption. The event
  # listener will also try to reconnect to the router is the router is reloaded.
  class EventListener
    include Socket::Constants
  
    # Socket to send commmands to the router
    attr_reader :in_socket
    # Socket to receive events from the router
    attr_reader :out_socket
    # Configuration settings for socket communication and event registration
    attr_reader :settings

    # Message type for registering a command interceptor
    def register_interceptor() 8; end
    
    # Connects to DCE router and register interceptor to receive certain events.
    # Events registration is specified in the config yml file. Once an event is
    # detected it will be put on beanstalk queue for workers consumption.
    # The following options must be specified:
    # * <tt>:router</tt> -- Specifies the ip address of the router
    # * <tt>:interceptor</tt> -- The device id for the event listener device
    def initialize( opts={} )
      logger.debug "Initializing Interceptor in `#{Rhouse.environment}"
      
      # check required args
      raise "No interceptor id specified" unless opts[:interceptor]
            
      config = YAML.load_file( Rhouse.confpath( "interceptor.yml" ) )
      raise "Unable to locate interceptor config `#{Rhouse.confpath( "interceptor.yml" )}" unless config 
      @settings = config[Rhouse.environment.to_s]      
      raise "Unable to load configuration for env #{Rhouse.environment}" unless @settings or @settings.empty?
      @settings['interceptor'] = opts[:interceptor]
      @settings['host']        = opts[:router] if opts[:router]
    end
    
    # Hangs out listening for incoming device events
    def listen_for_events
      trap_signals
      connect
      register_events
      listen
      close
    end
    
    # =========================================================================
    private
                  
      def queue
        # init beanstalkd connection
        @queue ||= Beanstalk::Pool.new( [ "#{config(:host)}:#{config(:beanstalk_port)}" ] )
        raise "Unable to connect to Beanstalk queue on '#{config(:host)}:#{config(:beanstalk_port)}" unless @queue
        @queue
      end
        
      # need to closeout sockets when program is interupted
      def trap_signals
        Signal.trap( 'KILL' ) do
          logger.debug( "!!!!!!!!!!!!!!!!! KILL intercepted !! " )
          close
          exit( 0 )
        end
        Signal.trap( 'INT' ) do
          logger.debug( "!!!!!!!!!!!!!!!!! INT intercepted !! " )          
          close
          exit( 0 )
        end
      end
        
      # retrieves configuration  
      def config( key )
        @settings[key.to_s]
      end
                
      # closeout connections
      def close
        unregister_interceptor
        logger.debug( "Closing out connections...." )
        in_socket.close
        out_socket.close
        logger.debug( "Done closing connections" )
      end

      # connect to DCE
      def connect        
        @in_socket  = Socket.new( AF_INET, SOCK_STREAM, 0 )
        @out_socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
        
        begin
          in_socket.connect( Socket.pack_sockaddr_in( config(:port), config(:host) ) )        
          out_socket.connect( Socket.pack_sockaddr_in( config(:port), config(:host) ) )
        rescue => boom
          logger.error( "Doh !! Unable to connect to router with #{config(:host)}:#{config(:port)}" )
          logger.error boom
          exit( 1 )
        end
        
        logger.debug "Setting receiving connection #{config(:interceptor)}"
        in_socket.send( "COMMAND #{config(:interceptor)}\n", 0 )
        check_ok_response( in_socket, "Setting up command channel" )

        logger.debug "Setting up event connection #{config(:interceptor)}"
        out_socket.send( "EVENT #{config(:interceptor)}\n", 0 )
        check_ok_response( out_socket, "Setting up event channel" )        
        
        sleep 1

        logger.debug "Registering for plain text messages"
        out_socket.send( "PLAIN_TEXT\n", 0 )
        check_ok_response( out_socket, "Registering plain text messages" )
        
        logger.debug "Finished initializing"
      end

      # check for ok response     
      def check_ok_response( socket, msg )
        resp = socket.recv( 100 )
        logger.debug "#{msg} => '#{resp}'"
        raise "Unable to #{msg}" unless resp.index( /^OK/)
      end
      
      # Tells the router that we are interested in certain events
      def register_events
        events = config( :events )
        events.each_pair do |event_id, message_type|
          logger.debug "Registering for message intercepts #{event_id} - #{message_type}"
          command =  "#{config(:interceptor)} #{config(:dce_id)} #{register_interceptor} 0 5 #{message_type} 4 #{event_id}"
          logger.debug "Command #{command} -- #{command.size}"    
          out_socket.send( "MESSAGET #{command.size}\n#{command}\n" , 0 )
          check_ok_response( out_socket, "Registering #{event_id} interception" )
        end
        logger.debug "Finished event registration"
      end    
  
      # unregister interceptor from dce router
      def unregister_interceptor
        logger.debug "<<< UnRegistering for message interceptor #{config(:interceptor)}"
        command =  "#{config(:interceptor)} #{config(:dce_id)} 13 0 5 1 4 73"
        logger.debug "Command #{command} -- #{command.size}"    
        out_socket.send( "MESSAGET #{command.size}\n#{command}\n" , 0 )
        logger.debug "Finished unregistration"
      end
   
      # push event to beanstalk queue for workers consumption
      def queue_notification( event )       
        queue.put( event )
      end
         
      # process trapped events
      def process_msg( msg )        
        return if msg.index( /.*?\"&\"$/)
        logger.debug ">>> TRAPPED EVENT '#{msg}'"        
        begin
          queue_notification( msg )
        rescue => boom
          logger.error "Hoy !! Unable to enqueue message on beanstalk queue"
          logger.error boom
        end
      end
      
      # is this a shutdown notification ?
      def is_shutdown?( msg )
        return false if msg.index( /&/ )
        tokens = msg.split( " " )
        tokens[2].to_i == 7
      end

      # process an event notification
      def process_notification
        size = in_socket.readline.strip!
        msg  = in_socket.read( size.to_i )
        
        msg.strip!
        logger.debug "GOT Event: '#{msg}'"              

        if is_shutdown?( msg )
          process_shutdown( msg )
        else
          process_msg( msg )
          in_socket.send( "OK\n", 0 )
        end
      end
      
      # handles shutdown msg
      def process_shutdown( msg )
        logger.debug "!!! Router is shutting down !!!"
        close
        logger.debug "Sleeping for #{config(:sleep_interval)} secs..."
        sleep( config(:sleep_interval) )
        connect
        register_events        
      end
      
      # listen for event notifications
      def listen
        logger.debug "Listening...."
        loop do
          logger.debug "Waiting for event..."
          if data = in_socket.read( 9 )
            data.strip!
            logger.debug ""
            logger.debug "Receiving '#{data}'"
            if data == 'MESSAGET'
              process_notification
            # responds to ping from router...
            elsif ( data == "PING" )
              logger.debug ">>>>> Sending PONG"           
              out_socket.send( "PONG\n", 0 )
            else
              ; # do nothing ?
            end
          else
            close
            puts "Sleeping..."
            sleep( config(:sleep_interval) )
            connect
            register_events
          end
          break if Rhouse.test_env?
        end
        logger.debug "!!!!!!!!!!!!!! Bailing out !!!!!!!!!!!!!!!!"
      end      
      
      def logger
        Rhouse.logger
      end
      
  end
end