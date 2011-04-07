require 'test/unit'
require 'active_support'

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  @@reserved_ivars = %w(@loaded_fixtures @test_passed @fixture_cache @method_name @_assertion_wrapped @_result)
  @@last_gc_run = Time.now

  # Add more helper methods to be used by all tests here...
  self.setup do
    begin_gc_deferment
    puts "#{subject.class} - #{@method_name}" if ENV['TRACE']
  end

  self.teardown do
    reconsider_gc_deferment
    truncate_tables :all if ENV['TRUNCATE']
    scrub_instance_variables
  end

  def scrub_instance_variables
    (instance_variables - @@reserved_ivars).each do |ivar|
      instance_variable_set(ivar, nil)
    end
  end

  def begin_gc_deferment
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def reconsider_gc_deferment
    if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable

      @@last_gc_run = Time.now
    end
  end

end