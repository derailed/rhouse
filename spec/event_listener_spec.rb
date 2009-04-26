require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))
require 'beanstalk-client'

describe Rhouse::EventListener do
  
  before( :all ) do
    @interceptor = Rhouse::EventListener.new( :router => 'localhost', :interceptor => 100 )
  end
    
  it "should have a logger set" do
    @interceptor.send( :logger ).should_not be_nil
    @interceptor.send( :logger ).should be_instance_of( Rhouse::Logger )
  end
  
  it "should pull the correct configuration" do
    @interceptor.send(:config, :port ).should == 3450
  end
  
  it "should push msg on queue correctly" do
    queue = stub( Beanstalk::Pool )
    msg   = "Blee"
    Beanstalk::Pool.should_receive( :new ).exactly(1).and_return( queue )
    queue.should_receive( :put ).exactly(1).with( msg ).and_return( queue )    
    @interceptor.send( :queue_notification, msg )
  end
  
  it "can load settings correctly" do
    settings = @interceptor.settings            
    settings['port'].should           == 3450
    settings['sleep_interval'].should == 30
    settings['dce_id'].should         == -1000
    settings['events'].should         == {83=>2, 84=>2, 73=>1, 13=>2, 140=>1}
    settings['host'].should           == 'localhost'
    settings['interceptor'].should    == 100
  end

  describe "connecting to router" do
    before( :each ) do
      @in_socket  = stub(Socket, :connect => "connected" )
      @out_socket = stub(Socket, :connect => "connected" )
    end
  
    it "should setup up the listener correctly" do
      @interceptor.should_receive( :in_socket ).exactly(0).and_return( @in_socket )
      @interceptor.should_receive( :out_socket ).exactly(0).and_return( @out_socket )
      
      @interceptor.should_receive( :trap_signals ).once
      @interceptor.should_receive( :connect ).once
      @interceptor.should_receive( :register_events ).once
      @interceptor.should_receive( :listen ).once
      @interceptor.should_receive( :close ).once                
      @interceptor.listen_for_events
    end
  
    it "should exit if the router can not be found" do
      @in_socket = stub(Socket, :connect => nil )
      @interceptor.should_receive( :in_socket ).exactly(1).and_return( @in_socket )      
      logger = stub( Rhouse::Logger )
      @interceptor.should_receive( :logger ).exactly(2).and_return( logger )
      logger.should_receive( :error ).twice      
      lambda do
        @interceptor.send( :connect )
      end.should raise_error( SystemExit )
    end
    
    it "should connect to DCE router correctly" do
      @interceptor.should_receive( :in_socket ).at_least(3).and_return( @in_socket )
      @interceptor.should_receive( :out_socket ).at_least(3).and_return( @out_socket )    
    
      Socket.should_receive( :new ).exactly(2)
      Socket.should_receive( :pack_sockaddr_in ).with( 3450, 'localhost' ).exactly(2).and_return( "some_address" )
    
      @in_socket.should_receive( :connect ).with( 'some_address' ).and_return( "connected" )
      @in_socket.should_receive( :send ).with( "COMMAND 100\n", 0 ).exactly(1).and_return( "OK\n" )
      @in_socket.should_receive( :recv ).with( 100 ).exactly(1).and_return( "OK\n" )    
    
      @out_socket.should_receive( :connect ).with( 'some_address' ).and_return( "connected" )    
      @out_socket.should_receive( :send ).with( "EVENT 100\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :recv ).with( 100 ).exactly(2).and_return( "OK\n" )
      @out_socket.should_receive( :send ).with( "PLAIN_TEXT\n", 0 ).exactly(1).and_return( "OK\n" )    
    
      @interceptor.send( :connect )
    end
  
    it "traps signals correctly" do
      Signal.should_receive( :trap ).with( 'KILL' ).once
      Signal.should_receive( :trap ).with( 'INT' ).once
      @interceptor.send( :trap_signals )
    end

    it "close the connection with the router correctly" do
      @interceptor.should_receive( :in_socket ).and_return( @in_socket )
      @interceptor.should_receive( :out_socket ).at_least( 2 ).and_return( @out_socket )
    
      @in_socket.should_receive( :close ).exactly( 1 )
      
      @out_socket.should_receive( :close ).exactly( 1 )
      @out_socket.should_receive( :send ).with( "MESSAGET 23\n100 -1000 13 0 5 1 4 73\n", 0 ).exactly(1).and_return( "OK\n" )      
      
      @interceptor.send( :close )
    end
  
    it "register events correctly" do
      @interceptor.should_receive( :out_socket ).at_least( 2 ).and_return( @out_socket )
      @out_socket.should_receive( :send ).with( "MESSAGET 22\n100 -1000 8 0 5 2 4 83\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :send ).with( "MESSAGET 22\n100 -1000 8 0 5 2 4 84\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :send ).with( "MESSAGET 22\n100 -1000 8 0 5 2 4 13\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :send ).with( "MESSAGET 22\n100 -1000 8 0 5 1 4 73\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :send ).with( "MESSAGET 23\n100 -1000 8 0 5 1 4 140\n", 0 ).exactly(1).and_return( "OK\n" )
      @out_socket.should_receive( :recv ).with( 100 ).exactly(5).and_return( "OK\n" )    
      @interceptor.send( :register_events )
    end
  end
    
  describe '#listen' do
    before( :each ) do
      @in_socket  = stub(Socket, :connect => "connected" )
      @out_socket = stub(Socket, :connect => "connected" )
    end

    it "should identify a shutdown message correctly" do
      @interceptor.send( :is_shutdown?, "0 1 7" ).should == true
      @interceptor.send( :is_shutdown?, "0 35 9 0 \"&\" 0 28 1 192" ).should == false      
    end

    it "should process a shutdown message correctly" do
      msg = "0 1 7"      
      @interceptor.should_receive( :sleep ).once      
      @interceptor.should_receive( :close ).once
      @interceptor.should_receive( :connect ).once
      @interceptor.should_receive( :register_events ).once      
      @interceptor.send( :process_shutdown, msg )
    end
    
    it "should detect a shutdown message correctly" do
      msg = "0 1 7"
      @interceptor.should_receive( :in_socket ).at_least( 1 ).and_return( @in_socket )
      @in_socket.should_receive( :readline ).once.and_return( "#{msg.size}\n" )
      @in_socket.should_receive( :read ).with( msg.size ).and_return( msg )
      @interceptor.should_receive( :process_shutdown ).with( msg ).once
      @interceptor.send( :process_notification )
    end
    
    it "should process a message correctly" do
      msg = "0 35 9 0 \"&\" 0 28 1 192"
      @interceptor.should_receive( :in_socket ).at_least( 1 ).and_return( @in_socket )
      @in_socket.should_receive( :readline ).once.and_return( "#{msg.size}\n" )
      @in_socket.should_receive( :read ).with( msg.size ).and_return( msg )
      @in_socket.should_receive( :send ).with( "OK\n", 0 ).once
      @interceptor.should_receive( :queue_notification ).with( msg ).once
      @interceptor.send( :process_notification )
    end
    
    it "should return a pong msg on a ping" do
      @interceptor.should_receive( :in_socket ).at_least( 1 ).and_return( @in_socket )        
      @interceptor.should_receive( :out_socket ).at_least( 1 ).and_return( @out_socket )
      @in_socket.should_receive( :read ).with( 9 ).and_return( "PING" )
      @out_socket.should_receive( :send ).with( "PONG\n", 0).and_return( "OK\n" )
      @interceptor.send( :listen )
    end
    
    it "should process a message correctly" do
      @interceptor.should_receive( :in_socket ).at_least( 1 ).and_return( @in_socket )        
      @interceptor.should_receive( :out_socket ).exactly( 0 )
      @in_socket.should_receive( :read ).with( 9 ).and_return( "MESSAGET" )
      @interceptor.should_receive( :process_notification ).exactly(1)
      @interceptor.send( :listen )    
    end
    
    it "should log an exception if unable to contact message queue" do
      logger = stub( Rhouse::Logger )
      @interceptor.should_receive( :logger ).exactly(3).and_return( logger )
      logger.should_receive( :debug ).once
      logger.should_receive( :error ).twice
      @interceptor.should_receive( :queue_notification ).with( "0 35 9 0 \"&\" 0 28 1 192" ).and_raise( "Blee" )
      @interceptor.send( :process_msg, "0 35 9 0 \"&\" 0 28 1 192")
    end
  end
end