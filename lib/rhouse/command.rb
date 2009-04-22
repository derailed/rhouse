module Rhouse
  # Connects to the DCE router and send device commands. A command use the same
  # format whether it's a command for lighting, turning on the tv and recording 
  # a frame on a wireless camera. The basic command morphology is make up of the
  # following information:
  # device_id, command_id, params
  # * <tt>device_id</tt>  The database ID for the device to connect to
  # * <tt>command_id</tt> The database ID for the command to send out to the device
  # * <tt>parameters</tt> A collection of key/value pairs, where the key is the parameter
  #   database ID for the parameter associated with the command above.
  class Command
 
    # Sends raw command to the DCE Router.
    # Example send_raw( :device_id => 28, :command_id => 184, 76 => 60 )
    def self.send_raw( params={} )      
      # validate device exists?
      device_id = params.delete( :device_id )
      device = Rhouse::Models::Device.find( device_id, :include => :template )
      raise "Unable to locate device `#{device_id}" unless device

      # validate command exists?
      commands = device.commands
      command_id = params.delete( :command_id ).to_i
      command  = commands.select { |c| c.cmd_id == command_id }.first rescue nil
      raise "Unable to find command #{command_id}" unless command

      # send command to router            
      send_cmd( device.id, command, params )
    end
    
    # Send human 'readable' command to the DCE Router.
    # Example send_human( 'office', desk lamp', 'on' )
    def self.send_human( location, appliance, command, params=[] )
      # validate location exists?
      room = Rhouse::Models::Room.find_by_Description( location )
      raise "Unable to locate room #{location}" unless room
      
      # validate device exists?
      device = Rhouse::Models::Device.find_by_Description_and_FK_Room( appliance, room.id, :include => :template )
      raise "Unable to locate device `#{appliance}" unless device      
      
      # validate command exists?
      cmd = device.commands.select { |cmd| cmd.name == command }.first rescue nil
      raise "Unable to find command on device `#{device.Description} -- `#{command}" unless cmd
        
      # send command to router
      send_cmd( device.id, cmd, map_params( cmd, params_to_hash( params ) ) )
    end
            
    private
    
      # sent command to router
      def self.send_cmd( device_id, command, parameters={}, command_type="r" )
        result = nil
        Rhouse::MessageSend.send do |sender|
          cmd    = formulate_cmd( command_type, device_id, command.cmd_id, parameters )
          logger.debug( "Sending `#{cmd}..." )          
          result = sender.send_command( cmd )
          logger.debug( "Sent `#{cmd} ==> #{result}")
          return result
        end
      end
      
      # prepare command format to be sent to the router            
      def self.formulate_cmd( command_type, device_id, command_id, parameters={} )
        cmd = "-%s 0 %d 1 %d" % [command_type, device_id, command_id]
        params = []
        parameters.each_pair { |k,v| params << k; params << v }
        "#{cmd} #{params.join( ' ' )}"
      end
      
      # converts params array pairs in hash
      def self.params_to_hash( parameters )
        args = {}
        params = parameters.clone
        while !params.empty? do
          args[params.shift] = params.shift
        end
        args
      end
      
      # merge command params
      def self.map_params( command, overrides )
        parameters = {}
        command.params.each do |param|
          value = overrides[param.name] || "\"\""
          parameters[param.param_id] = value
        end
        parameters
      end
            
      # default logger...
      def self.logger
        Rhouse.logger
      end
      
  end
end