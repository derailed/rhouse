# This module is a collection of A/R models to interact with the pluto database.
# We have not modeled every single instances as there are over 200 tables. We've
# only models part of the persistence layer that is directly applicable with the
# RHouse gem. More models will be added, as the gem grows...
module Rhouse::Models
end

require 'active_record'

Rhouse.require_all_libs_relative_to( __FILE__ )
