require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))

# require 'mocha'
# require 'spec/mocks'
# require 'spec/mocks/mock'


describe Rhouse::MessageSend do

  before( :each ) do
    @out_socket = stub(Socket, :connect => "connected" )
    @sender     = Rhouse::MessageSend.new
  end

  it "should connect to DCE router correctly" do
    @sender.should_receive( :out_socket ).at_least(3).and_return( @out_socket )    
    @sender.should_receive( :check_router ).once
      
    Socket.should_receive( :new ).exactly(1)
    Socket.should_receive( :pack_sockaddr_in ).with( 3450, 'localhost' ).exactly(1).and_return( "some_address" )
    
    @out_socket.should_receive( :connect ).with( 'some_address' ).and_return( "connected" )  
    @out_socket.should_receive( :recv ).with( 100 ).exactly(2).and_return( "OK\n" )    
    @out_socket.should_receive( :send ).with( "EVENT -1003\n", 0 ).and_return( "OK\n" )
    @out_socket.should_receive( :send ).with( "PLAIN_TEXT\n", 0 ).exactly(1).and_return( "OK\n" )    
  
    @sender.send( :connect )
  end

  it "check if router is ready for cmds correctly" do
    @sender.should_receive( :out_socket ).exactly(2).and_return( @out_socket )              
    @out_socket.should_receive( :send ).with( "READY\n", 0 ).once.and_return( "YES\n" )
    @out_socket.should_receive( :recv ).with( 100 ).exactly(1).and_return( "YES\n" )  
    @sender.send( :check_router )
  end

  it "close the connection with the router correctly" do
    @sender.should_receive( :out_socket ).at_least( 1 ).and_return( @out_socket )
    @out_socket.should_receive( :close ).exactly( 1 )
    @sender.send( :close )
  end

  it "should send a command correctly" do
    @sender.should_receive( :out_socket ).at_least( 1 ).and_return( @out_socket )
    @out_socket.should_receive( :send ).with( "MESSAGET 32\n0 34 9 0 \"&\" 0 37 1 200 41 \"500\"\n", 0 ).exactly(1).and_return( "OK\n" )
    @out_socket.should_receive( :recv ).with( 100 ).exactly(1).and_return( "OK\n" )    
    @sender.send_command( "0 34 9 0 \"&\" 0 37 1 200 41 \"500\"" )
  end
    
end