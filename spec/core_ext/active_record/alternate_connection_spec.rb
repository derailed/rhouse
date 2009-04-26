require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper] ) )

describe Rhouse::Extensions::AlternateConnections do
  it "defines .with_alternate_connection method on ActiveRecord::Base" do
    ActiveRecord::Base.should respond_to(:with_alternate_connection)
  end
  
  describe ".with_alternate_connection" do
    before(:all) do
      # Rhouse.initialize( :log_level => "debug", :connect_to_db => true ) 
    end

    before(:each) do
      @pool = mock( "connection pool" )
    end

    after(:each) do
      ActiveRecord::Base.connection_handler.connection_pools.delete "media_test"
    end
    
    describe "when no connection pool exists for the alternate environment" do
      
      it "establishes a new connection pool, yields, and puts the original pool back" do
        ActiveRecord::ConnectionAdapters::ConnectionPool.should_receive(:new).and_return(@pool)
        yielded = false
        original = ActiveRecord::Base.connection_pool
        ActiveRecord::Base.with_alternate_connection( "media_test" ) do
          yielded = true
          ActiveRecord::Base.connection_pool.should == @pool
        end
        yielded.should be_true
        ActiveRecord::Base.connection_pool.should == original
      end
    end
    
    describe "when a connection pool already exists for the alternate environment" do
      before(:each) do
        ActiveRecord::Base.connection_handler.connection_pools["media_test"] = @pool
      end

      it "does not establish a new connection pool" do
        ActiveRecord::ConnectionAdapters::ConnectionPool.should_not_receive(:new)
        original = ActiveRecord::Base.connection_pool
        yielded = false
        ActiveRecord::Base.with_alternate_connection( "media_test" ) do
          yielded = true
          ActiveRecord::Base.connection_pool.should == @pool
        end
        yielded.should be_true
        ActiveRecord::Base.connection_pool.should == original
      end
    end
    
    describe "when no connection pool exists for the class" do
      before(:each) do
        @prev = ActiveRecord::Base.connection_handler.connection_pools.delete "ActiveRecord::Base"
        ActiveRecord::ConnectionAdapters::ConnectionPool.should_receive(:new).and_return(@pool)
      end
      after(:each) do
        ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"] = @prev
      end

      it "does not replace the connection pool with nil" do
        ActiveRecord::Base.with_alternate_connection( "media_test" ) do
        end
        ActiveRecord::Base.connection_handler.connection_pools.should_not have_key("ActiveRecord::Base")
      end
    end    
  end
  
end