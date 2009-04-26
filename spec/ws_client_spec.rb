require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))

describe Rhouse::WsClient do

  before( :each ) do
    @response = mock( RFuzz::HttpResponse )
  end
    
  it "should load the right configuration" do
    Rhouse::WsClient.send( :config, :host ).should        == "localhost"
    Rhouse::WsClient.send( :config, :rhouse_port ).should == 6666
  end
  
  it "should send a command via the web service correctly" do
    server = stub( RFuzz::HttpClient )    
    server.should_receive( :post ).with( 
      '/cmd', 
      { :head => { "Content-type" => "application/x-www-form-urlencoded" }, 
        :body => "command_id=30&device_id=20" } ).and_return( @response )
    @response.should_receive( :http_status ).and_return( "200" )
    @response.should_receive( :http_body ).at_least( 1 ).and_return( "OK" )
    Rhouse::WsClient.should_receive( :rhouse_service ).and_return( server )    
    result = Rhouse::WsClient.send_cmd( :device_id => 20, :command_id => 30 )
    result.should == "OK"
  end

  it "should send a service request correctly" do
    server = stub( RFuzz::HttpClient )    
    server.should_receive( :get ).with( '/test/me' ).and_return( @response )
    @response.should_receive( :http_status ).and_return( "200" )
    @response.should_receive( :http_body ).at_least( 1 ).and_return( "OK" )
    Rhouse::WsClient.should_receive( :rhouse_service ).and_return( server )    
    result = Rhouse::WsClient.service( "/test/me" )
    result.should == "OK"
  end

  it "should raise an exceptiomn if the command fails" do
    server = stub( RFuzz::HttpClient )
    
    Rhouse::WsClient.should_receive( :rhouse_service ).and_return( server )
    server.should_receive( :post ).with( 
      '/cmd', 
      { :head => { "Content-type" => "application/x-www-form-urlencoded" }, 
        :body => "command_id=30&device_id=20" } ).and_return( @response )
    @response.should_receive( :http_status ).and_return( "404" )
    @response.should_receive( :http_reason ).and_return( "crap" )
    
    lambda {
      Rhouse::WsClient.send_cmd( :device_id => 20, :command_id => 30 )
    }.should raise_error( /querying RHouse/ )
  end
    
end
