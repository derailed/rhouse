require 'ostruct'

module Rhouse
  # Parse a device event. Needs to identify the device the event came from as
  # well as the type of event and it's parameters. Parses the event into a 
  # consumable ostruct.
  class EventParser

    # Is this a shutdown event?
    def self.shutdown?( command_type )
      command_type.to_i == 7
    end
    
    # Check if this is an event or a command
    def self.command?( command_type )
      command_type.to_i == 1
    end    
    
    # Cleanse the message before parsing
    def self.cleanse( message )
      message.strip!
      event = message
      event = message[message.index(/&/ )+3, message.size] if message.index( /&/ )
      event = event.gsub( /-o\s/, '' ) if event.index( /^-o/ )
      event      
    end
    
    # Parse out event into a device_id, to_device_id, type and event_id
    def self.event_info( event )
      tokens = event.split( /\s/ )
      return tokens[0], tokens[1], tokens[2], tokens[3]
    end
    
    # Identifies event and parses out parameters
    def self.parse( message )
      event = cleanse( message )
      from_id, to_id, command_type, event_id = event_info( event )
            
      # identify device_id
      if command?( command_type ) or shutdown?( command_type )
        device_id = to_id
      else
        device_id = from_id
      end
      
      chop_index = from_id.size + to_id.size + command_type.size + event_id.size + 4      
      OpenStruct.new(
        :device_id    => device_id.to_i,
        :command_type => command_type.to_i,
        :command_id   => event_id.to_i,
        :parameters   => parse_parameters( event_id.to_i, command_type.to_i, event[chop_index, event.size] )
        )
    end
    
    # Parses event parameters into a hash
    def self.parse_parameters( command_id, command_type, params_string )
      params = {}
      return params if !params_string or params_string.empty?
      
      if command?( command_type )
        event = Rhouse::Models::Command.find( command_id, :include => :command_parameters )
      elsif shutdown?( command_type )
        event = Rhouse::Models::Command.find( command_type, :include => :command_parameters )
      else
        event = Rhouse::Models::Event.find( command_id, :include => :event_parameters )
      end

      event.parameters.each do |param|
        regexp = Regexp.new( "#{match_param_id( param )}\s\"(#{match_type(param.param_type)})\"" )
        value  = params_string.match( /#{match_param_id( param )}\s\"(#{match_type(param.param_type)})\"/ )
        if value and value.captures
          params[param.param_id] = cast_to_type( param.param_type, value.captures.first )
        else
          raise "Unable to parse event parameter for event `#{command_id} parameter #{param.param_id}"
        end
      end
      params
    end
    
    # Check data type for param. ie Data may be encoded
    def self.match_param_id( param )
      return "U#{param.param_id}" if param.param_type == "Data"
      param.param_id        
    end
    
    # TODO !! May need better handling
    # Casts parameter to correct type
    def self.cast_to_type( param_type, param_value )
      case param_type
        when 'string' : param_value
        when 'int'    : param_value.to_i
        when 'bool'   : param_value.to_i
        when 'double' : param_value.to_f
        when 'Data'   : Base64.decode64( param_value )
        else param_value
      end
    end
    
    # TODO !! May need better handling
    # Fetch correct regex parameter type match
    def self.match_type( param_type )
      case param_type
        when 'string' : ".*?"
        when 'Data'   : ".*?"
        else "\\d*"
      end
    end    
  end
end