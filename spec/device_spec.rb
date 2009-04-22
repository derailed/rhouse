require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))

describe Rhouse::Models::Device do
  
  before( :all ) do
    @lamp = Rhouse::Models::Device.find( 42 )
    @lamp.should_not be_nil    
  end
  
  it "should have the right template" do  
    @lamp.template.should_not be_nil
    @lamp.template.Description.should == "Light Switch (dimmable)"
  end
  
  it "should have the right commands for a lamp" do
    @lamp.commands.should_not be_nil 
    @lamp.commands.should have(3).items   
    @lamp.commands.map{ |c| c.name }.sort.should == [ 'Off', 'On', 'Set Level' ]
  end
  
  it "should have the right parameter for set level" do
    cmd = @lamp.commands.select{ |c| c if c.name == "Set Level" }
    cmd.compact!
    cmd.should have(1).item
    
    params = cmd.first.params
    params.should have(1).item
    
    c = params.first
    c.name.should       == "Level"
    c.param_id.should   == 76
    c.param_type.should == 'string'
  end
  
  it "should list out all light fixtures" do
    lights = Rhouse::Models::Device.all_lights
    lights.should have(1).item
    lights.first.Description.should == "Office dimmable light"
  end

  it "should list out all light fixtures" do
    cams = Rhouse::Models::Device.all_ip_cams
    cams.should have(1).item
    cams.first.Description.should == "Panasonic IP Camera"
  end

end