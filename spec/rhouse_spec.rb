require 'rubygems'
require 'spec'

path = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift path unless $:.include? path

describe Rhouse do
  before(:each) do
    Rhouse.initialize( :environment => :test, :log_level => :debug )
    @root_dir = File.expand_path( File.join( File.dirname(__FILE__), %w[..] ) )
  end 

  it "has a version" do
    Rhouse.version.should =~ /\d+\.\d+\.\d+/
  end 
  
  it "should log to a file correctly" do
    Rhouse.reset
    Rhouse.initialize( :environment => :test, :log_level => :debug, :log_file => "/tmp/blee.log" )
    Rhouse.logger.log_file_appender.class.name.should == "Logging::Appenders::RollingFile"
  end

  it "has a valid configuration" do
    Rhouse.config.should_not                 be_nil
    Rhouse.config[:environment].should       == :test
    Rhouse.config[:log_level].should         == :debug
    Rhouse.config[:requires_db].should       == false    
    Rhouse.config[:email_alert_level].should == :error
    Rhouse.config[:log_file].should          == $stdout    
  end
  
  it "finds things relative to 'lib'" do
    Rhouse.libpath( *%w[rhouse]).should == File.join( @root_dir, %w[lib rhouse] )
  end 
    
  it "should produce a debug dump" do
    Rhouse.logger.should_receive( :<< ).exactly( 7 )
    Rhouse.dump
  end
  
  it "finds things relative to 'root'" do
    Rhouse.path("Rakefile").should == File.join( @root_dir, "Rakefile" )
  end
  
  it "provides its logger upon request" do 
    Rhouse.logger.should be_instance_of( Rhouse::Logger )
  end

  it "provides the same logger instance" do
    logger = Rhouse.logger
    logger.should equal( Rhouse.logger )
  end
end
