#require 'capybara/cucumber'
require 'ruby-debug'

require "#{File.dirname(__FILE__)}/../core/warden"
require "#{File.dirname(__FILE__)}/../lib/lib_steps"
require "#{File.dirname(__FILE__)}/../lib/cucumber_formatter"
require "#{File.dirname(__FILE__)}/../lib/link_checker"
require "#{File.dirname(__FILE__)}/../lib/price_rogue"
require "#{File.dirname(__FILE__)}/../lib/page_objects"
require "#{File.dirname(__FILE__)}/../config/sauce_connect_config"
World(Warden)

#require './selenium_remote'
#Capybara.app = "Google"
# module Capybara
  # include Warden
# end
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 0

# Cleanup log folder before run, this needs to be more
# sophisticated.
FileUtils.rm Dir.glob("#{ENV["WARDEN_HOME"]}log/*.yaml")

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :selenium #:sauce for Sauce Connect driver
  #config.default_driver = :sauce #for Sauce Connect driver
  config.default_wait_time = 20 #for ajax heavy site, site it to a higher number
end


Before do |scenario|
  #browser.open()
  @warden_session = Warden::Warden_Session.new(scenario)
  #make feature data avaiable in steps
  @fd = OpenStruct.new( @warden_session.feature_data() )
end

After do |scenario|
  begin
    @warden_session.capture_screen_shot()# if scenario.failed?
    
    if scenario.failed? and ENV["WARDEN_DEBUG_MODE"] == "true"
      print "\nYou are in ruby debug mode.\n"
      print scenario.exception.message + "\n"
      print scenario.exception.backtrace.join("\n")
      print "\n\n"
      Debugger.start do
        debugger
        puts "OK."
      end
    end
  rescue Exception => e
    #display any exception in the After block, otherwise it will be captured
    #sinked by Cucumber
    print "\n"
    print "Exception happened inside the After hook:"
    print e.message
    print e.backtrace[0..10].join("\n")
    raise e
  end

end

# AfterStep do |scenario|
  

# end

