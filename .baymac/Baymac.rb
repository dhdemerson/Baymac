require 'rubygems'
require 'Open3'
require_relative 'utilities'
require_relative 'homebrew'
require_relative 'cask'
require_relative 'mackup'

# TODO: Progressive text presentation, reduced pause time
# TODO: Check if Baymac is in a synced folder, if not complain

class Baymac
  def initialize(verbose, fast)
    @verbose = verbose
    @fast = fast

    # TODO: Get these hooked up to IOX

    @homebrew = Homebrew.new
    @cask = Cask.new(@homebrew)
    @mackup = Mackup.new

    # TODO: Be creepier here

    $IOX.say "Hello! I am Baymac. Your personal setup companion."
    $IOX.say "I can do either of the following:"

    $IOX.list [
      { head: "Setup", body: "this computer"},
      { head: "Configure", body: "how I setup computers"}
    ]

    # Main loop
    while (true)
      response = $IOX.ask "? What would you like me to do (setup/configure/quit): "

      case
      when "setup".include?(response.downcase)
        setup()
      when "configure".include?(response.downcase)
        configure()
      when "quit".include?(response.downcase)
        $IOX.say "Goodbye!"
        abort
      else
        $IOX.say "I'm sorry I didn't understand that..."
      end
    end
  end

  def configure
    $IOX.say "Okay let's configure how I setup computers"
    if $IOX.ynq "When I setup a computer should I install software"
      @cask.setApps(configSoftware())
    else
      @cask.setApps([])
    end

    $IOX.say "I can also manage configurations for popular applications"
    if $IOX.ynq "When I setup a computer should I sync configurations"
      # TODO: Configure applications to sync
      # TODO: Clarify nature of syncing configs
      mackupBackup()
    end

    $IOX.say "I am configured and ready to setup computers!"
  end

  def setup
    $IOX.say "Setting up your computer..."
    @cask.installApps
    @mackup.restore
    $IOX.say "Everything is all setup!"
  end

  def mackupBackup
    checkMackup()
    @mackup.backup
  end

  def configSoftware()
    checkHomebrew()
    checkCask()

    oldApps = @cask.apps
    apps = []

    if @cask.apps.length > 0
      $IOX.say "Previously I was configured to install the following:"
      apps = chooseSoftware(@cask.apps)
      # If they keep or select from old config subtract those apps
      # Otherwise show all apps
      if apps.length == 0
        oldApps = apps
      end
    end

    $IOX.say "Okay, let me see what you have installed..."

    # Get installed applications
    files = Dir.entries('/Applications/') - Utilities::MAC_DEFAULT_APPS
    # Ignore applications installed from the app store
    files.delete_if {|file| File.exist?("/Applications/#{file}/Contents/_MASreceipt/receipt")}
    files.concat(Dir.entries(ENV['HOME'] + '/Applications/'))
    files.delete_if {|file| file.start_with? '.'}
    files.map{|file| file.slice! ".app"}

    exacts = []
    partials = []

    files.each do |app|
     o, s = Open3.capture2e("brew cask search #{app}")
     o = o.lines
     if o[0].include?("Exact match")
       exacts << o[1]
     elsif o[0].include?("Partial")
       partials.concat(o.slice(1..o.length))
     end
   end
   exacts.map{|cask| cask.slice! "\n"}
   partials.map{|cask| cask.slice! "\n"}
   casks, s = Open3.capture2e("brew cask list")
   unless casks.include?("Warning")
     casks = casks.split
     exacts.concat(casks)
   end
   exacts.uniq!
   partials.uniq!
   # Hide apps they've already made decisions about
   exacts = exacts - oldApps
   partials = partials - (exacts + oldApps)

   if exacts.length > 0
     $IOX.say "I found the following applications:"
     apps = apps + chooseSoftware(exacts)
   end
   if partials.length > 0
     $IOX.say "I was less sure about the following applications:"
     apps = apps + chooseSoftware(partials)
   end
   $IOX.say "When I setup a computer I will install the following:"
   $IOX.list apps
   return apps
  end

  def chooseSoftware(list)
    $IOX.list(list)
    $IOX.say "When I setup a computer I can install any of these"
    response = $IOX.ask('? Install these applications when I setup (yes/no/some): ')
    case
    when "yes".include?(response.downcase)
      return list
    when "no".include?(response.downcase)
      return []
    when "some".include?(response.downcase)
      selections = []
      $IOX.say "Choose which applications should be installed when I setup a Mac\n"
      $IOX.increaseIndentLevel
      list.each do |listItem|
        if $IOX.agree("? Automatically install <%= BOLD %>#{listItem}<%= CLEAR %> (y/n): ")
          selections << listItem
        end
      end
      $IOX.decreaseIndentLevel
      return selections
    end
  end

  def checkMackup
    unless @mackup.installed?
      $IOX.say "It seems that Mackup is not installed"
      $IOX.say "To copy configurations for applications I need Mackup"
      if @homebrew.installed?
        if $IOX.ynq "Would you like me to install Mackup from Homebrew"
          @mackup.install
        end
      end
    end

    # TODO: Ensure mackup is up to date

    unless @mackup.installed?
      $IOX.sad "Without Mackup I can't work properly... Goodbye"
      abort
    end
  end

  def checkHomebrew
    unless @homebrew.installed?
      $IOX.say "It seems that the Homebrew package manager is not installed"
      $IOX.say "I will need Homebrew installed before I can proceed"

      if $IOX.ynq "May I begin the installation procedure for Homebrew"
        @homebrew.install
      end

      unless @homebrew.installed?
        $IOX.sad "Without Homebrew I can't work properly... Goodbye!"
        abort
      end
    end

    unless @homebrew.upToDate?
      if $IOX.ynq "May I update Homebrew if it is not the latest version"
        @homebrew.update
      end
    end
  end

  def checkCask
    unless @cask.installed?
      $IOX.say "It seems the Cask package is not installed for Homebrew"
      $IOX.say "I will need Cask installed before I can proceed"

      if $IOX.ynq "May I install Cask for Homebrew"
        @cask.install
      end

      unless @cask.installed?
        $IOX.sad "Without Cask I can't work properly... Goodbye!"
        abort
      end
    end
  end
end
