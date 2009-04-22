require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))

describe Rhouse::Command do

  before( :all ) do
    @device = Rhouse::Models::Device.find( 42, :include => :template )
    @device.should_not be_nil

    @commands = @device.commands
    @command  = @commands.select { |c| c.cmd_id == 193 }.first
    @command.should_not be_nil    
  end
    
  it "should send a raw command correctly" do        
    params = { :device_id => @device.id, :command_id => 193 }
    Rhouse::Command.should_receive( :send_cmd ).once.with( @device.id, @command, params )
    Rhouse::Command.send_raw( params )
  end
    
  it "should formulate a command correctly" do
    Rhouse::Command.formulate_cmd( "r", 28, 184, { 76 => 80 } ).should == "-r 0 28 1 184 76 80"
  end
  
  it "should formulate play song command correctly" do
    xine = Rhouse::Models::Device.find( 22, :include => :template )
    xine.should_not be_nil

    commands = xine.commands
    command  = commands.select { |c| c.cmd_id == 37 }.first
        
    Rhouse::Command.should_receive( :send_cmd ).once.with( 
      22, 
      command, 
      { 29 => 4, 41 => 1003, 42 => 0, 59 => '%2Fhome%2Ffred%2Ftest.mp3' } 
    )
    Rhouse::Command.send_human( 
      "Office", 
      "Xine Player", 
      'Play Media',     
      [
        "PK_MediaType" , 4, 
        "StreamID"     , 1003, 
        'MediaPosition', 0, 
        'MediaURL'     , CGI.escape( '/home/fred/test.mp3' )
      ] 
    )
  end
  
  it "should send a human command correctly" do
    command = @commands.select { |c| c.cmd_id == 192 }.first 
    Rhouse::Command.should_receive( :send_cmd ).once.with( @device.id, command, {97 => 100, 98 => "\"\"" } )
    Rhouse::Command.send_human( "Office", "Office dimmable light", 'On', ["PK_Pipe", 100] )
  end
  
  it "should map parameters correctly" do
    command = @commands.select { |c| c.cmd_id == 192 }.first 
    params = Rhouse::Command.map_params( command, { "PK_Pipe" => 100, "PK_Device_Pipes" => 200 } )
    params.should == { 97 => 100, 98 => 200 }
  end
  
  it "should send a message to router correctly" do
    Rhouse::MessageSend.should_receive( :send ).once.and_return( "OK\n" )
    Rhouse::Command.send_cmd( 42, @command, {} ).should == "OK\n"
  end
  
  it "should have the right logger set" do
    Rhouse::Command.logger.should == Rhouse.logger
  end
end
