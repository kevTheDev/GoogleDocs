require 'bundler'
require "bundler/setup"
require 'test/unit'
require 'active_support'
require 'rr'
require 'shoulda'
require 'gdata4ruby'
require 'factory_girl'



require 'google_docs/service'

class ActiveSupport::TestCase
  
  include RR::Adapters::TestUnit
  
  Factory.find_definitions 
  

end