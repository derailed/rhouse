# This module is a collection of A/R models to interact with the pluto_media database.
# We have not modeled every single instances, we've only modeled part of the persistence 
# layer that is directly applicable with the RHouse gem. 
# More models will be added, as the gem grows...
module Rhouse::Models::Media
end

require 'active_record'

Rhouse.require_all_libs_relative_to( __FILE__ )
