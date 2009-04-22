require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))
require 'ostruct'

describe Rhouse::Worker do

  before( :all ) do
  end

  it "should set the worker name correctly" do
    worker = Rhouse::Worker.new( "test" )
    worker.name.should == 'test'
  end
  
  it "should compile the correct config file name" do
    worker = Rhouse::Worker.new( "The Worker" )
    worker.send( :config_file_name ).should == "the_worker"    
  end
  
  it "should raise an exeption if no implementing class" do
    worker = Rhouse::Worker.new( "test" )
    lambda do
      worker.wait_for_event
    end.should raise_error( Exception, /configuration_file/ )
  end      
  
  it "should raise an exception if protocol is not correctly implemented" do
    class LameAssWorker < Rhouse::Worker
      def configuration_file
        File.expand_path( File.join( File.dirname(__FILE__), 'config', 'test_worker.yml' ) )
      end
    end
    @worker = LameAssWorker.new( "test" )
    queue = stub( Beanstalk::Pool, :reserve => OpenStruct.new( :body => "blee" ) )
    @worker.should_receive( :queue ).once.and_return( queue )    
    @worker.should_receive( :connect ).once
    lambda do
      @worker.wait_for_event
    end.should raise_error( Exception, /handle_event/ )
    # logger.should_receive( :error ).twice    
  end

  describe "good worker" do
    before( :each ) do
      class BusyWorker < Rhouse::Worker
        def handle_event( evt )
          evt.should == "blee"
        end
        def configuration_file
          File.expand_path( File.join( File.dirname(__FILE__), 'config', 'test_worker.yml' ) )
        end
      end
      @worker = BusyWorker.new( "test" )
    end
    
    it "should close the queue connection upon exiting" do
      queue = mock( Beanstalk::Pool, :null_object => true )
      @worker.should_receive( :queue ).once.and_return( queue )
      queue.should_receive( :close ).once
      @worker.send( :close )
    end
    
    it "should process events correctly" do
      queue = stub( Beanstalk::Pool, :reserve => OpenStruct.new( :body => "blee" ) )    
      @worker.should_receive( :connect ).once
      @worker.should_receive( :queue ).at_least( 1 ).and_return( queue )
      @worker.wait_for_event    
    end
  end
end
