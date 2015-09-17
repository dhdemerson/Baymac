require 'rubygems'
require 'Open3'
require 'highline'
require_relative 'utilities'

# TODO: Refactor speech and io
# TODO: Progressive text presentation, reduced pause time
# TODO: Extract main

class Baymac
  BAYMAC = "[<%= color('·_·', BOLD) %>] "
  SAD_BAYMAC = "[._.] "

  def initialize(verbose, fast)
    @verbose = verbose
    @fast = fast

    # Homebrew
    @homebrewInstalled = checkCommand('type brew')
    @homebrewUpToDate = false

    # Cask
    @caskInstalled = checkCommand('brew cask')
    @caskUpToDate = false

    # Mackup
    @mackupInstalled = checkCommand('type mackup')
    @mackupUpToDate = false

    @terminal = HighLine.new
    @terminal.indent_size = 3
    @terminal.wrap_at = @terminal.terminal_size[0]

    say "Hello! I am Baymac. Your personal setup companion."
    say "I can do either of the following:"

    # Word wrap messes up if these are on the same line :/
    @terminal.say "\n<%= color('Scan', BOLD) %> this computer for applications I can automatically install and configurations that can be copied when I setup a new Mac."
    @terminal.say "\n<%= color('Setup', BOLD) %> this computer installing applications, transfering configurations, and running bootstrap scripts."

    while (true)
      response = ask "? What would you like me to do (scan/setup/quit): "

      case
      when "scan" == response.downcase
        scan()
      when "setup" == response.downcase
        setup()
      when "quit".include?(response.downcase)
        say "Goodbye!"
        abort
      else
        say "I'm sorry I didn't understand that try 'scan', 'setup', or 'quit'"
      end
    end
  end

  def pause(seconds)
    sleep seconds unless @fast
  end

  def runCommand(cmd, autoFail=true)
    Open3.popen2e(cmd) do |stdin, stdout_and_stderr, wait_thr|

      if (@verbose)
        puts "\n" + cmd
        while line = stdout_and_stderr.gets
          puts line
        end
      end
      if !wait_thr.value.success? && autoFail
        say "There was a problem executing command: #{cmd}"
        unless @verbose
          puts stdout_and_stderr.read
        end
        abort "Please copy and paste the output and report to..."
      end
    end
  end

  def checkCommand(cmd)
    stdouterr, status = Open3.capture2e("#{cmd}")
    status.success?
  end

  def sadSay(input)
    @terminal.say "\n" + SAD_BAYMAC + input
  end

  def say(input, pause=true)
    @terminal.wrap_at = @terminal.terminal_size[0]
    @terminal.say "\n" + BAYMAC + input #"<%= color('#{input}', BLUE) %>"
    pause(input.split.size / 4) if pause #240 WPM
  end

  def ask(question)
    @terminal.ask("\n" + BAYMAC + question)
  end

  def list(lines, indent_level = 2)
    @terminal.indent_level = indent_level
    lines.each do |line|
      if line.is_a? String
        @terminal.say "• <%= color('#{line}', BOLD) %>"
      elsif line.is_a? Object
        @terminal.say "• <%= color('#{line[:head]}', BOLD) %> #{line[:body]}"
      end
    end
    @terminal.indent_level = 0
  end

  def add(input)
    @terminal.say input
    pause(input.split.size / 4) #240 WPM
  end

  def scan
    say "When I setup a new Mac I can install software automatically"
    if ynq "Scan this Mac for software I can install automatically"
      puts "scanning for software"
      matchSoftware()
    end

    say "I can also copy configurations and settings for popular applications"
    if ynq "Scan this Mac for configurations and settings to copy"
      mackupBackup()
    end
  end

  def setup
    # TODO: Install software
    # TODO: Mackup restore
  end

  def mackupBackup
    checkMackup()

    unless File.exist?(ENV['HOME'] + "/.mackup.cfg")
      say "Configuration not found!"
    end

    say "Out!"


    # TODO: use provided config or use our default
    # TODO: Run mackup backup
    # TODO: Run scripts

  end

  def matchSoftware
    checkHomebrew()
    checkCask()

    unless @homebrewInstalled && @caskInstalled
      sadSay "I am unable to scan for software without Homebrew and Cask"
      return
    end

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
   partials = partials - exacts
   return exacts, partials
  end

  def presentList(list, prompt)
    list(list)

    response = ask(prompt + ' (yes/no/some): ')
    case
    when "yes".include?(response.downcase)
      return list
    when "no".include?(response.downcase)
      return []
    when "some".include?(response.downcase)
      selections = []
      say "Choose which applications should be installed when I setup a Mac"
      @terminal.indent_level = 2
      list.each do |listItem|
        if @terminal.agree("\n? Automatically install <%= BOLD %>#{listItem}<%= CLEAR %> (y/n): ")
          selections << listItem
        end
      end
      @terminal.indent_level = 0
      return selections
    end
  end

  def ynq(question)
    while(true)
      response = ask("? #{question} (yes/no/quit): ")
      case
      when "yes".include?(response.downcase)
        return true
      when "no".include?(response.downcase)
        return false
      when "quit".include?(response.downcase)
        sadSay "Okay... Goodbye!"
        abort
      end
      say "I'm sorry I didn't understand"
    end
  end

  def checkMackup
    unless @mackupInstalled
      say "To copy configurations and settings for applications I need Mackup"
      if @homebrewInstalled
        if ynq "Would you like me to install Mackup from Homebrew"
          say("Installing Mackup... ", false)
          runCommand("brew install mackup")
          # TODO: Check success
          @terminal.say "Done."
          @mackupInstalled = true
          @mackupUpToDate = true
        end
      end
    end

    unless @mackupInstalled && @mackupUpToDate
      if ynq "May I update Mackup if it is not the latest version"
        say "Not implemented"
        # TODO: update mackup if it is installed via homebrew or pip
      end
    end
  end

  def checkHomebrew
    unless @homebrewInstalled
      say "It seems that the Homebrew package manager is not installed"
      say "I will be unable scan for or install software without Homebrew"
      unless ynq "May I begin the installation procedure for Homebrew"
        return
      end
      say "Okay, running the Homebrew installation script"
      say "This process may prompt you for your password"
      system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
      unless checkCommand('type brew')
        sadSay "It seems like Homebrew did not install properly."
        return
      end
      @homebrewInstalled = true
      @homebrewUpToDate = true
      say "Homebrew installed!"
    end

    unless @homebrewInstalled && @homebrewUpToDate
      if ynq "May I update Homebrew if it is not the latest version"
        say("Updating Homebrew... ", false)
        runCommand("brew update")
        # TODO: Check success
        @terminal.say "Done."
        @homebrewUpToDate = true
      end
    end
  end

  def checkCask
    unless @homebrewInstalled && @caskInstalled
      say "It seems the Cask package is not installed for Homebrew"
      say "I will be unable to scan for or install software without Cask"
      unless ynq "May I install Cask for Homebrew"
        return
      end
      runCommand("brew install caskroom/cask/brew-cask")
      # TODO: Check cask installation
      say "Homebrew Cask installed!"
      @caskInstalled = true
      @caskUpToDate = true
    end

    unless @homebrewInstalled && @caskInstalled && @caskUpToDate
      if ynq "May I update Homebrew Cask if it is not the latest version"
        say("Updating Homebrew Cask... ", false)
        runCommand("brew upgrade brew-cask", false)
        # TODO: Check succdss
        @terminal.say "Done."
      end
    end
  end
end
