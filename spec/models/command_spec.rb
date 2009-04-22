require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Rhouse::Models::Command do

  it "should find the correct parameters for a shutdown command" do
    cmd = Rhouse::Models::Command.find( 7, :include => :command_parameters )
    cmd.should_not be_nil
    cmd.parameters.should have(0).items
  end
  
  it "should find the associated parameters correctly" do
    cmd = Rhouse::Models::Command.find( 184, :include => :command_parameters )
    cmd.should_not be_nil
    
    params = cmd.parameters
    params.should have(1).items
    names = [ 
      { :type => 'string', :name => 'Level'}, 
    ]
    
    count = 0
    params.each do |param|
      param.name.should == names[count][:name]
      param.param_type.should == names[count][:type]
      count += 1
    end
  end
    
end
