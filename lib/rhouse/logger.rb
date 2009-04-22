require 'logging'
require 'forwardable'
require 'socket'

module Rhouse
  # Rhouse using the most excellent logging gem for all loging needs. This
  # sets up the correct appenders for the Rhouse gem.
  class Logger
    class ConfigurationError < Rhouse::Error ; end
    
    extend Forwardable
    
    attr_reader :log # here for testing, don't really use it.

    def_delegators :@log, :debug, :warn, :info, :error, :fatal 
    def_delegators :@log, :level=, :level
    def_delegators :@log, :debug?, :warn?, :info?, :error?, :fatal?  
    def_delegators :@log, :add, :clear_appenders
    def_delegators :@log, :<<

    def self.default_options
      @default_options ||= {
        # log event layout pattern
        #    YYYY-MM-DDTHH:MM:SS 12345 LEVEL LoggerName : The Log message
        #
        :layout_pattern       => '%d %5p %5l %c : %m\n'.freeze  ,
        :logger_name          => Rhouse                         ,
        :additive             => true                           ,

        # log file configuration options
        #   age        -> how often to rotate the logs if a file is used
        #   keep_count -> how many of the log files to keep
        :log_level            => :info          ,
        :log_file             => $stdout        ,
        :log_file_age         => 'daily'.freeze ,
        :log_file_keep_count  => 7              ,

        # email logging options
        #   buffsize -> number of log events used as a threshold to send an
        #               email.  If that is not reached before the program
        #               exists then the at_exit handler for logging will flush
        #               the log to smtp.
        :email_alerts_to      => nil                 ,
        :email_alert_level    => :error              ,
        :email_alert_server   => "localhost".freeze  ,
        :email_alert_buffsize => 200                 ,
      }
    end

    # Creates a new logger
    def initialize( opts = {} )
      @options = Rhouse::Logger.default_options.merge(opts)
      @log     = Logging::Logger[@options[:logger_name]]
      @layout  = Logging::Layouts::Pattern.new( { :pattern => @options[:layout_pattern] } )
   
      # add appenders explicitly, since this logger may already be defined and
      # already have loggers
      @appenders = []
      @appenders << log_file_appender if @options[:log_file]
      @appenders << email_appender    if @options[:email_alerts_to]

      @log.appenders = @appenders
      @log.level     = @options[:log_level]
      @log.additive  = @options[:additive]
    end

    # File appender, this is either an IO appender or a RollingFile appender
    # depending on if an IO object or a String is passed in.
    # A configuration error is raised in any other circumstance
    def log_file_appender
      appender_name = "#{@log.name}-log_file_appender"
      if String === @options[:log_file] then 
        ::Logging::Appenders::RollingFile.new( appender_name, 
                                             { :layout    => @layout,
                                               :filename  => @options[:log_file],
                                               :age       => @options[:log_file_age],
                                               :keep      => @options[:log_file_keep_count],
                                               :safe      => true  # make sure log files are rolled using lockfile
        })
      elsif @options[:log_file].respond_to?(:print) then
        ::Logging::Appenders::IO.new( appender_name, @options[:log_file],  :layout => @layout  )
      else
        raise ConfigurationError, "Invalid :log_file option [#{@options[:log_file].inspect}]"
      end
    end

    # An email appender that uses :email_alerts_to option to send emails to.
    # :email_alerts_to can either be a singe email address as a string or an
    # Array of email addresses.  Any other option for :email_alerts_to is
    # invalid and raises an error.
    def email_appender
      email_alerts_to = [ @options[:email_alerts_to] ].flatten.reject { |x| x == nil }
      raise ConfigurationError, "Invalid :email_alerts_to option [#{@options[:email_alerts_to].inspect}]" unless email_alerts_to.size > 0
      ::Logging::Appenders::Email.new("#{@log.name}-email_appender",
        {
          :level    => @options[:email_alert_level],
          :layout   => @layout,
          :from     => "rh-logger@#{Socket.gethostname}",
          :to       => "#{email_alerts_to.join(', ')}",
          :subject  => "Logging Alert from #{@log.name} on #{Socket.gethostname}",
          :server   => @options[:email_alert_server],
          :buffsize => @options[:email_alert_buffsize], # lines 
        })
    end
  end
end