require 'beanstalk-client'

module Rhouse
  # Observes events on the beanstalk queue. This is meant to be an abstract base 
  # class for all workers. Derived classes must implement the handle_event and 
  # configuration_file protocol.  
  class Worker    
    # The name of the worker
    attr_reader :name
    # The configuration hash loaded from the configuration YAML file
    attr_reader :config
    # A Handle to the beanstalk queue
    attr_reader :queue
    # The name of the environment the worker operates against
    attr_reader :environment

    # Initializes the worker for a given environemt
    def initialize( worker_name, environment='test' )
      @name        = worker_name
      @environment = environment
    end

    # Hang on queue, waiting for events
    def wait_for_event
      load_configuration
      connect
      init_rhouse
      trap_signals
      
      loop do
        logger.debug ">>> Connected to queue #{config['host']}:#{config['beanstalk_port']}"
        logger.debug "Waiting for work..."      
        job = queue.reserve
        evt = job.body
        handle_event( evt )
        if config['consume_events'] == true
          logger.debug "*** Deleting from queue : #{evt}"
          job.delete 
        end
        break if environment == "test"
      end      
    end

    # =========================================================================
    protected

      # Process the event. Here your worker can do anything with this event. 
      # Virtual protocol. This must be implemented in your derived classes.    
      def handle_event( msg )
        raise "Not implemented. You must implement the method #handle_event in your derived class"
      end

      # Computes the yaml configuration filename. Virtual protocol. You must implement this
      # method in your derived class.
      def configuration_file
        raise "Not implemented. You must implement the method #configuration_file in your derived class"
      end
           
    # =========================================================================
    private
 
       # Loads configuration from yml file    
      def load_configuration
        config  = YAML.load_file( configuration_file )
        raise "Unable to locate worker config `#{configuration_file}" unless config     
        @config = config[environment]
        raise "Unable to find configuration for environment #{environment}" unless @config or @config.empty?
      end

      # Fetch the name of the configuration yaml file. 
      # Usually named after the worker name
      def config_file_name
        config_name = name.downcase
        config_name.gsub( / /, '_' )
      end
      
      # Handle to the logger
      def logger
        Rhouse.logger
      end
            
      # Handle kill events. Close out connection when interupted
      def trap_signals
        Signal.trap( 'KILL' ) do
          logger.debug( "Worker #{name} interupted[KILL]. Exiting..." )
          close
          exit( 0 )
        end
        Signal.trap( 'INT' ) do
          logger.debug( "Worker #{name} interupted[INT]. Exiting..." )
          close
          exit( 0 )
        end
      end
   
      def connect
        @queue = Beanstalk::Pool.new( ["#{config['host']}:#{config['beanstalk_port']}"] )
      end
      
      # Closes out connection with beanstalkd
      def close
        queue.close
      end
   
      # Initializes Rhouse environment
      def init_rhouse
        ::Rhouse.initialize( 
          :environment => config['db_env'] || :test, 
          :requires_db => config['requires_db'] || false,
          :log_level   => config['log_level'] || :info,
          :log_file    => config['log_file'] || $stdout )
        # ::Rhouse.dump
      end
  end
end