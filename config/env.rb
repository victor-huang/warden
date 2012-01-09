#require 'capybara/cucumber'
require 'sauce'
require 'ruby-debug'
require "#{File.dirname(__FILE__)}/../lib/lib_steps"
require "#{File.dirname(__FILE__)}/../core/warden"

World(Warden)

#require './selenium_remote'
#Capybara.app = "Google"
# module Capybara
  # include Warden
# end
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 0

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :selenium
  config.default_wait_time = 20 #for ajax heavy site, site it to a higher number
end

require 'sauce/capybara'

Sauce.config do |config|
  config.username = ""
  config.access_key = ""
  config.browser = "firefox"
  config.os = "Windows 2003"
  config.browser_version = "7"
end





Before do |scenario|
  #debugger
  #browser.open()
  @warden_session = Warden::Warden_Session.new(scenario)
  #make feature data avaiable in steps
  @fd = OpenStruct.new( @warden_session.feature_data() )

end

After do |scenario|
  begin
    embed_screenshot("screenshot-#{Time.new.to_i}", scenario) # if scenario.failed?
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
    puts 
    puts "Exception happened inside the After hook:"
    puts e.message
    puts scenario.exception.backtrace.join("\n")
    raise e
  end

end

# AfterStep do |scenario|
  

# end

