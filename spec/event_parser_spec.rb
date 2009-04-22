require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Rhouse::EventParser do
  
  describe "#parse" do

    # it "should parse a partial command correctly" do
    #   message = Rhouse::EventParser.parse( "\n0 37 1 193\n" )
    #   message.should_not          be_nil
    #   message.should              be_instance_of( OpenStruct )
    #   message.device_id.should    == 37
    #   message.command_type.should == 1
    #   message.command_id.should   == 193
    # end

    it "should parse an event correctly" do
      message = Rhouse::EventParser.parse( "0 35 9 0 \"&\" 40 -1001 2 9 25 \"1\"" )
      message.should_not            be_nil
      message.should                be_instance_of( OpenStruct )
      message.device_id.should      == 40
      message.command_type.should   == 2
      message.command_id.should       == 9
      message.parameters.should_not be_nil
      message.parameters[25].should  == 1
    end
    
    it "should parse shutdown message correctly" do
      message = Rhouse::EventParser.parse( "0 35 7 1 1 \"1\"" )
      message.should_not          be_nil
      message.should              be_instance_of( OpenStruct )
      message.device_id.should    == 35
      message.command_type.should == 7
      message.command_id.should   == 1
      message.parameters.should   be_empty
    end
    
    it "should parse a message with no arguments correctly" do
      message = Rhouse::EventParser.parse( "\n0 34 9 0 \"&\" 0 37 1 193\n" )      
      message.should_not be_nil
      message.should be_instance_of( OpenStruct )      
      message.device_id.should    == 37
      message.command_type.should == 1
      message.command_id.should   == 193
      message.parameters.should   be_empty
    end

    it "should parse a message with argument correctly" do
      message = Rhouse::EventParser.parse( "\n0 34 9 0 \"&\" 0 37 1 200 41 \"500\"\n" )
      message.should_not            be_nil
      message.should                be_instance_of( OpenStruct )      
      message.device_id.should      == 37
      message.command_type.should   == 1
      message.command_id.should     == 200
      message.parameters.should_not be_nil
      message.parameters.should     have(1).item
      message.parameters[41].should == 500
    end

    it "should parse a camera frame capture event correctly" do
      message = Rhouse::EventParser.parse( "\n0 34 9 0 \"&\" 0 35 1 84 20 \"jpg\" 23 \"\" 41 \"10\" 60 \"640\" 61 \"400\" U19 \"L3RtcC9ibGVl\"\n" )
      message.should_not             be_nil
      message.should                 be_instance_of( OpenStruct )
      message.device_id.should       == 35
      message.command_type.should    == 1
      message.command_id.should      == 84
      message.parameters.should_not  be_nil
      
      message.parameters.size.should == 6      
      message.parameters[23].should  == ""
      message.parameters[41].should  == 10
      message.parameters[20].should  == "jpg"
      message.parameters[60].should  == 640
      message.parameters[61].should  == 400
      message.parameters[19].should  == "/tmp/blee"
    end
    
    it "should parse a message set up for delivery confirmation correctly" do      
      message = Rhouse::EventParser.parse( "0 34 9 0 \"&\" -o 0 37 1 200 41 \"500\"" )
      message.should_not            be_nil
      message.should                be_instance_of( OpenStruct )      
      message.device_id.should      == 37
      message.command_type.should   == 1
      message.command_id.should     == 200
      message.parameters.should_not be_nil
      message.parameters[41].should == 500      
    end
    
    it "should decode a music event correctly" do
      message = Rhouse::EventParser.parse( "0 35 9 0 \"&\" 22 -1001 2 58 4 \"/home/public/data/audio/B-Side Players/Movement/10 Baila 1.mp3\" 9 \"1003\" 16 \"\" 47 \"pcm\" 48 \"\"" )
      message.should_not            be_nil
      message.should                be_instance_of( OpenStruct )      
      message.device_id.should      == 22
      message.command_type.should   == 2
      message.command_id.should     == 58
      message.parameters.should     have(5).items      
      message.parameters[4].should  == "/home/public/data/audio/B-Side Players/Movement/10 Baila 1.mp3"
      message.parameters[9].should  == 1003
      message.parameters[16].should == ""
      message.parameters[47].should == "pcm"
      message.parameters[48].should == ""
      
    end
  end
end
