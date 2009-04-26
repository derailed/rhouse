# ------------------------------------------------------------------------------
# Improved db query loggin to show where the connection comes from
#
# author: fernand
# -----------------------------------------------------------------------------
module ActiveRecord::ConnectionAdapters
  class AbstractAdapter
    
    def log_info(sql, name, runtime)
      if @logger && @logger.debug?
        host = @connection_options[0]
        user = @connection_options[1]
        db   = @connection_options[3]
        name = ">> SQL (#{host}/#{user}) -- #{db.nil? ? "" : db} (#{sprintf("%f", runtime)})"
        @logger.debug format_log_entry( name, sql.squeeze(' ') )
      end
    end
    
  end
end
