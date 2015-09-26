#!/usr/bin/env ruby

require 'main'
require_relative '.baymac/Baymac'
require_relative '.baymac/IOX'

Main {

  name 'baymac'
  author 'Hayden Demerson'
  version '0.0.1'

  option('verbose=[verbose]') {
      description 'Show output for all commands'
      cast :boolean
      defaults true
  }

  option('fast=[fast]') {
    description 'Do not pause after Baymac speaks'
    cast :boolean
    defaults true
  }

  def run
    verbose = params['verbose'].given? && params['verbose'].value
    fast = params['fast'].given? && params['fast'].value

    $IOX = IOX.instance()

    @baymac = Baymac.new(verbose, fast)



    #@baymac.say "I can install software, copy configurations, and run scripts."

    #this should be stored as state in Baymac

    # if not configged || new
    # config["last_run"] = Time.now

    # config["name"] = @baymac.ask "? What is your name: "
    # @baymac.say "Hello #{config["name"]}, it is nice to meet you."
    # @baymac.say "Let's get started."
    # File.open('.baymac/config.yml', 'w') {|f| f.write config.to_yaml}

    # => update
    # if configged
    # @baymac.say "Hello 'name', how can I help you?" ? Is this a new machine?
    # Menu: update, setup

    # Prepare should be silent

    # @baymac.say "Scanning for "
    # @baymac.say "Let me take a look around..."
    #@baymac.say "Scanning installed applications..."
    #(exacts, partials) = @baymac.scan
    #@baymac.say "In the future I can automate installation of the following applications:"
    #casks = @baymac.presentList(exacts + partials, 'Install these applications when I setup a Mac?')
    #File.open('software/casks.yml', 'w') {|f| f.write casks.to_yaml}
  end
}
