require File.expand_path(File.join(File.dirname(__FILE__), %w[spec_helper]))

describe Rhouse::WsClient do

  before( :each ) do
    @client   = Rhouse::WsClient.new
    @response = mock( RFuzz::HttpResponse )
  end
    
  it "should load the right configuration" do
    @client.send( :config, :host ).should        == "localhost"
    @client.send( :config, :rhouse_port ).should == 6666
  end
  
  it "should send a command via the web service correctly" do
    server = stub( RFuzz::HttpClient )
    
    @client.should_receive( :rhouse_service ).and_return( server )
    server.should_receive( :post ).with( 
      '/cmd', 
      { :head => { "Content-type" => "application/x-www-form-urlencoded" }, 
        :body => "command_id=30&device_id=20" } ).and_return( @response )
    @response.should_receive( :http_status ).and_return( "200" )
    @response.should_receive( :http_body ).at_least( 1 ).and_return( "OK" )
    result = @client.send_cmd( :device_id => 20, :command_id => 30 )
    result.should == "OK"
  end

  it "should raise an exceptiomn if the command fails" do
    server = stub( RFuzz::HttpClient )
    
    @client.should_receive( :rhouse_service ).and_return( server )
    server.should_receive( :post ).with( 
      '/cmd', 
      { :head => { "Content-type" => "application/x-www-form-urlencoded" }, 
        :body => "command_id=30&device_id=20" } ).and_return( @response )
    @response.should_receive( :http_status ).and_return( "404" )
    @response.should_receive( :http_reason ).and_return( "crap" )
    
    lambda {
      @client.send_cmd( :device_id => 20, :command_id => 30 )
    }.should raise_error( /querying RHouse/ )
  end
    
end
