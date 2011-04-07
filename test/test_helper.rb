require 'bundler'

Bundler.require(:default, :development)

require 'test/unit'
require 'active_support'

class ActiveSupport::TestCase
  
  include RR::Adapters::TestUnit
  

end