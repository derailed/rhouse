require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Rhouse::Models::Event do

  before( :each ) do
    @event = Rhouse::Models::Event.find( 58, :include => :event_parameters )
    @event.should_not be_nil
  end
    
  it "should find the associated parameters correctly" do
    params = @event.parameters
    params.should have(5).items
    names = [ 
      { :type => 'string', :name => 'MRL'}, 
      { :type => 'int'   , :name => 'Stream ID' },
      { :type => 'string', :name => 'SectionDescription' },
      { :type => 'string', :name => 'Audio' },
      { :type => 'string', :name => 'Video' }
    ]
    
    count = 0
    params.each do |param|
      param.name.should == names[count][:name]
      param.param_type.should == names[count][:type]
      count += 1
    end
  end
    
end
