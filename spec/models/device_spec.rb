require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Rhouse::Models::Device do

  before( :each ) do
    @device = Rhouse::Models::Device.find( 42, :include => :template )
    @device.should_not be_nil
  end
    
  it "should find a command by name" do
    cmd = @device.find_command( "Set Level" )    
    cmd.should_not    be_nil
    cmd.name.should   == "Set Level"
    cmd.cmd_id.should == 184
    
    cmd.params.should           have(1).item
    param = cmd.params.first
    param.name.should       == "Level"
    param.param_id.should   == 76
    param.param_type.should == 'string' 
  end
  
  it "should return nil if a command does not exist" do
    @device.find_command( "Blee" ).should be_nil
  end
  
  it "should find a command parameters correctly" do
    param = @device.find_parameter( @device.find_command( "Set Level"), 'Level' )
    param.name.should       == "Level"
    param.param_id.should   == 76
    param.param_type.should == 'string'     
  end
  
  it "should return nil if a parameter is not found" do
    @device.find_parameter( @device.find_command( "Set Level"), 'fred' ).should be_nil
  end
  
end
